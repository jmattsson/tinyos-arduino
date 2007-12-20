
// Need to deal with non powers of base for the length of the hash

#include <DIP.h>

module DIPSummaryP {
  provides interface DIPDecision;

  uses interface DIPSend as SummarySend;
  uses interface DIPReceive as SummaryReceive;

  uses interface DIPHelp;
  uses interface DIPEstimates;

  uses interface Random;
}

implementation {
  void findRangeShadow(dip_index_t* left, dip_index_t *right);
  uint32_t buildRange(dip_index_t left, dip_index_t right);
  uint32_t computeHash(dip_index_t left, dip_index_t right,
		       dip_version_t* basedata, uint32_t salt);
  uint32_t computeBloomHash(dip_index_t left, dip_index_t right,
			    dip_version_t* basedata, uint32_t salt);
  void splitRange(uint32_t info, dip_index_t* left, dip_index_t* right);
  void adjustEstimatesSame(dip_index_t left, dip_index_t right);
  void adjustEstimatesDiff(dip_index_t left, dip_index_t rightt,
			   dip_version_t* data, uint32_t salt,
			   uint32_t bHash);

  uint8_t commRate;
  // this can be combined with pairs_t in DIPVectorP maybe?
  dip_estimate_t shadowEstimates[UQCOUNT_DIP];

  command uint8_t DIPDecision.getCommRate() {
    return commRate;
  }

  command void DIPDecision.resetCommRate() {
    commRate = 0;
  }

  command error_t DIPDecision.send() {
    dip_index_t i, j, left, right;
    dip_version_t* allVers;
    dip_estimate_t* allEsts;
    uint32_t salt;

    dip_msg_t* dmsg;
    dip_summary_msg_t* dsmsg;

    dmsg = (dip_msg_t*) call SummarySend.getPayloadPtr();
    dmsg->type = ID_DIP_SUMMARY;
    dsmsg = (dip_summary_msg_t*) dmsg->content;

    allVers = call DIPHelp.getAllVersions();
    allEsts = call DIPEstimates.getEstimates();
    salt = call Random.rand32();
    
    for(i = 0; i < UQCOUNT_DIP; i++) {
      shadowEstimates[i] = allEsts[i];
    }

    for(i = 0; i < DIP_SUMMARY_ENTRIES_PER_PACKET; i += 3) {
      findRangeShadow(&left, &right);
      dbg("DIPSummaryP", "Found range %u, %u\n", left, right);
      dsmsg->info[i] = buildRange(left, right);
      dsmsg->info[i+1] = computeHash(left, right, allVers, salt);
      dsmsg->info[i+2] = computeBloomHash(left, right, allVers, salt);
      for(j = left; j < right; j++) {
	shadowEstimates[j] = 0;
      }
      dbg("DIPSummaryP", "Hash Entry: %08x %08x %08x\n",
	  dsmsg->info[i], dsmsg->info[i+1], dsmsg->info[i+2]);
    }

    dsmsg->unitLen = DIP_SUMMARY_ENTRIES_PER_PACKET;
    dsmsg->salt = salt;

    for(i = 0; i < DIP_SUMMARY_ENTRIES_PER_PACKET; i += 3) {
      splitRange(dsmsg->info[i], &left, &right);
      adjustEstimatesSame(left, right);
    }

    return call SummarySend.send(sizeof(dip_msg_t) +
				 sizeof(dip_summary_msg_t) +
				 (sizeof(uint32_t) * DIP_SUMMARY_ENTRIES_PER_PACKET));
  }

  event void SummaryReceive.receive(void* payload, uint8_t len) {
    dip_summary_msg_t* dsmsg;
    uint8_t unitlen;
    uint32_t salt, myHash;
    uint8_t i;
    dip_index_t left, right;
    dip_version_t* allVers;

    commRate = commRate + 1;

    dsmsg = (dip_summary_msg_t*) payload;
    unitlen = dsmsg->unitLen;
    salt = dsmsg->salt;
    allVers = call DIPHelp.getAllVersions();
    
    for(i = 0; i < unitlen; i += 3) {
      splitRange(dsmsg->info[i], &left, &right);
      myHash = computeHash(left, right, allVers, salt);
      if(myHash != dsmsg->info[i+1]) {
	// hashes don't match
	adjustEstimatesDiff(left, right, allVers, salt, dsmsg->info[i+2]);
      }
      else {
	// hashes match
	adjustEstimatesSame(left, right);
      }
    }

  }

  void findRangeShadow(dip_index_t* left, dip_index_t *right) {
    dip_estimate_t est1;
    dip_estimate_t est2;
    dip_hashlen_t len;
    dip_index_t highIndex;
    dip_index_t i;
    dip_index_t LBound;
    dip_index_t RBound;
    uint16_t runEstSum;
    uint16_t highEstSum;
    
    // find highest estimate
    // initialize test
    highIndex = 0;
    est1 = shadowEstimates[0];

    // Get the highest estimate key
    for(i = 0; i < UQCOUNT_DIP; i++) {
      est2 = shadowEstimates[i];
      if(est2 > est1) {
	highIndex = i;
	est1 = est2;
      }
    }
    len = call DIPEstimates.estimateToHashlength(est1);
    dbg("DIPSummaryP","Highest key at %u with estimate %u and thus len %u\n",
	highIndex, est1, len);

    // initialize bounds on range
    if(highIndex < len - 1) { LBound = 0; }
    else { LBound = highIndex - len + 1; }
    if(LBound + len > UQCOUNT_DIP) { RBound = UQCOUNT_DIP; }
    else { RBound = highIndex + len; }

    // adjust length if necessary
    if(RBound - LBound < len) { len = RBound - LBound; }

    // initialize first range
    highEstSum = 0;
    highIndex = LBound;
    for(i = LBound; i < LBound + len; i++) {
      est1 = shadowEstimates[i];
      highEstSum += est1;
    }
    dbg("DIPSummaryP", "First range: %u, %u = %u\n", LBound, LBound + len,
	highEstSum);

    // iterate through the range
    runEstSum = highEstSum;
    dbg("DIPSummaryP", "Iterating from %u to %u\n", LBound, RBound);
    for(i = LBound ; i + len <= RBound; i++) {
      est1 = shadowEstimates[i];
      est2 = shadowEstimates[i + len];
      runEstSum = runEstSum - est1 + est2;
      // dbg("Dissemination","Next sum: %u\n", runEstSum);
      if(runEstSum > highEstSum) {
	highEstSum = runEstSum;
	highIndex = i + 1;
	dbg("DIPSummaryP", "Next range: %u, %u = %u\n", highIndex,
	    highIndex + len, highEstSum);
      }
    }

    // and finish
    *left = highIndex;
    *right = highIndex + len;
  }

  uint32_t buildRange(dip_index_t left, dip_index_t right) {
    uint32_t range;
    
    range = ((uint32_t) left << 16) | right;
    return range;
  }

  uint32_t computeHash(dip_index_t left, dip_index_t right,
		       dip_version_t* basedata, uint32_t salt) {
    dip_index_t i;
    uint32_t hashValue = salt;
    uint8_t *sequence; 

    if(right <= left) return 0;
    sequence = ((uint8_t*) (basedata + left));

    for(i = 0; i <= (right-left-1)*sizeof(dip_version_t); i++) {
      hashValue += sequence[i];
      hashValue += (hashValue << 10);
      hashValue ^= (hashValue >> 6);
    }
    hashValue += (hashValue << 3);
    hashValue ^= (hashValue >> 11);
    hashValue += (hashValue << 15);
    return hashValue;
  }

  uint32_t computeBloomHash(dip_index_t left, dip_index_t right,
			    dip_version_t* basedata, uint32_t salt) {
    dip_index_t i;
    uint32_t bit;
    uint32_t returnHash;
    uint32_t indexSeqPair[2];

    returnHash = 0;
    for(i = left; i < right; i++) {
      indexSeqPair[0] = i;
      indexSeqPair[1] = basedata[i];
      bit = computeHash(0, 2, indexSeqPair, salt) % 32;
      returnHash |= (1 << bit);
    }
    return returnHash;
  }

  void splitRange(uint32_t info, dip_index_t* left, dip_index_t* right) {
    *right = info & 0xFFFF;
    *left = (info >> 16) & 0xFFFF;
  }
  
  void adjustEstimatesSame(dip_index_t left, dip_index_t right) {
    dip_index_t i;

    for(i = left; i < right; i++) {
      call DIPEstimates.decEstimateByIndex(i);
    }
  }

  void adjustEstimatesDiff(dip_index_t left, dip_index_t right,
			   dip_version_t* data, uint32_t salt,
			   uint32_t bHash) {
    dip_index_t i;
    dip_estimate_t est;
    dip_key_t key;
    uint32_t indexSeqPair[2];
    uint32_t bit;

    est = call DIPEstimates.hashlengthToEstimate(right - left) + 1; // + 1 to improve search
    for(i = left; i < right; i++) {
      indexSeqPair[0] = i;
      indexSeqPair[1] = data[i];
      bit = computeHash(0, 2, indexSeqPair, salt) % 32;
      key = call DIPHelp.indexToKey(i);
      if(bHash & (1 << bit)) {
	//set estimate only if better
	call DIPEstimates.setSummaryEstimateByIndex(i, est);
      }
      else {
	dbg("DisseminationDebug", "Key %x definitely different\n", key);
	call DIPEstimates.setVectorEstimate(key);
      }
    }
  }

}