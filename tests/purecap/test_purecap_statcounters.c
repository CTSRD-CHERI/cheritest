/*-
 * Copyright (c) 2018 Alex Richardson
 * All rights reserved.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * @BERI_LICENSE_HEADER_START@
 *
 * Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
 * license agreements.  See the NOTICE file distributed with this work for
 * additional information regarding copyright ownership.  BERI licenses this
 * file to you under the BERI Hardware-Software License, Version 1.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at:
 *
 *   http://www.beri-open-systems.org/legal/license-1-0.txt
 *
 * Unless required by applicable law or agreed to in writing, Work distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * @BERI_LICENSE_HEADER_END@
 */

#include "../c/assert.h"

/* Test that the statcounters instructions work (mostly copied from cheribsd libstatcounters */
// FIXME: this should be an assembly language test (but for now this is quicker)

// Compat defines to make the cheribsd source file compile:
typedef __UINT64_TYPE__ uint64_t;

// counters bank
#define STATCOUNTERS_MAX_MOD_CNT 12
typedef struct statcounters_bank
{
    uint64_t itlb_miss;
    uint64_t dtlb_miss;
    uint64_t cycle;
    uint64_t inst;
    uint64_t icache[STATCOUNTERS_MAX_MOD_CNT];
    uint64_t dcache[STATCOUNTERS_MAX_MOD_CNT];
    uint64_t l2cache[STATCOUNTERS_MAX_MOD_CNT];
    uint64_t mipsmem[STATCOUNTERS_MAX_MOD_CNT];
    uint64_t tagcache[STATCOUNTERS_MAX_MOD_CNT];
    uint64_t l2cachemaster[STATCOUNTERS_MAX_MOD_CNT];
    uint64_t tagcachemaster[STATCOUNTERS_MAX_MOD_CNT];
} statcounters_bank_t;


// TODO the itlbmiss/dtlbmiss/cycle/inst counters are not reset with that
static inline void resetStatCounters (void)
{
	__asm __volatile(".word (0x1F << 26) | (0x0 << 21) | (0x0 << 16) | (0x7 << 11) | (0x0 << 6) | (0x3B)");
}

#define DEFINE_GET_STAT_COUNTER(name,X,Y)   \
static __attribute__((noinline)) uint64_t get_##name##_count (void)   \
{                                           \
    uint64_t ret;                           \
    __asm __volatile(".word (0x1f << 26) | (0x0 << 21) | (12 << 16) | ("#X" << 11) | ( "#Y"  << 6) | 0x3b\n\tmove %0,$12" : "=r" (ret) :: "$12"); \
    return ret;                             \
}



// available modules, module type, associated rdhw primary selector
//----------------------------------------------------------------------------
// instruction cache, CacheCore, 8
// data cache, CacheCore, 9
// level 2 cache, CacheCore, 10
// memory operations, MIPSMem, 11
// tag cache, CacheCore, 12
// level 2 cache master, MasterStats, 13
// tag cache master, MasterStats, 14

// module type : CacheCore
// available counter, associated rdhwr secondary selector
//----------------------------------------------------------------------------
// write hit, 0
// write miss, 1
// read hit, 2
// read miss, 3
// prefetch hit, 4
// prefetch miss, 5
// eviction, 6
// eviction due to prefetch, 7
// write of tag set, 8
// read of tag set, 9
enum
{
    STATCOUNTERS_WRITE_HIT     = 0,
    STATCOUNTERS_WRITE_MISS    = 1,
    STATCOUNTERS_READ_HIT      = 2,
    STATCOUNTERS_READ_MISS     = 3,
    STATCOUNTERS_PFTCH_HIT     = 4,
    STATCOUNTERS_PFTCH_MISS    = 5,
    STATCOUNTERS_EVICT         = 6,
    STATCOUNTERS_PFTCH_EVICT   = 7,
    STATCOUNTERS_SET_TAG_WRITE = 8,
    STATCOUNTERS_SET_TAG_READ  = 9
};
//----------------------------------------------------------------------------
// module type : MIPSMem
// available counter, associated rdhwr secondary selector
//----------------------------------------------------------------------------
// byte read, 0
// byte write, 1
// half word read, 2
// half word write, 3
// word read, 4
// word write, 5
// double word read, 6
// double word write, 7
// capability read, 8
// capability write, 9
enum
{
    STATCOUNTERS_BYTE_READ         = 0,
    STATCOUNTERS_BYTE_WRITE        = 1,
    STATCOUNTERS_HWORD_READ        = 2,
    STATCOUNTERS_HWORD_WRITE       = 3,
    STATCOUNTERS_WORD_READ         = 4,
    STATCOUNTERS_WORD_WRITE        = 5,
    STATCOUNTERS_DWORD_READ        = 6,
    STATCOUNTERS_DWORD_WRITE       = 7,
    STATCOUNTERS_CAP_READ          = 8,
    STATCOUNTERS_CAP_WRITE         = 9,
    STATCOUNTERS_CAP_READ_TAG_SET  = 10,
    STATCOUNTERS_CAP_WRITE_TAG_SET = 11
};
//----------------------------------------------------------------------------
// module type : MasterStats
// available counter, associated rdhwr secondary selector
//----------------------------------------------------------------------------
// read request, 0
// write request, 1
// write request flit, 2
// read response, 3
// read response flit, 4
// write response, 5
enum
{
    STATCOUNTERS_READ_REQ       = 0,
    STATCOUNTERS_WRITE_REQ      = 1,
    STATCOUNTERS_WRITE_REQ_FLIT = 2,
    STATCOUNTERS_READ_RSP       = 3,
    STATCOUNTERS_READ_RSP_FLIT  = 4,
    STATCOUNTERS_WRITE_RSP      = 5
};

DEFINE_GET_STAT_COUNTER(cycle,2,0);
DEFINE_GET_STAT_COUNTER(inst,4,0);
DEFINE_GET_STAT_COUNTER(itlb_miss,5,0);
DEFINE_GET_STAT_COUNTER(dtlb_miss,6,0);
DEFINE_GET_STAT_COUNTER(icache_write_hit,8,0);
DEFINE_GET_STAT_COUNTER(icache_write_miss,8,1);
DEFINE_GET_STAT_COUNTER(icache_read_hit,8,2);
DEFINE_GET_STAT_COUNTER(icache_read_miss,8,3);
DEFINE_GET_STAT_COUNTER(icache_evict,8,6);
DEFINE_GET_STAT_COUNTER(dcache_write_hit,9,0);
DEFINE_GET_STAT_COUNTER(dcache_write_miss,9,1);
DEFINE_GET_STAT_COUNTER(dcache_read_hit,9,2);
DEFINE_GET_STAT_COUNTER(dcache_read_miss,9,3);
DEFINE_GET_STAT_COUNTER(dcache_evict,9,6);
DEFINE_GET_STAT_COUNTER(dcache_set_tag_write,9,8);
DEFINE_GET_STAT_COUNTER(dcache_set_tag_read,9,9);
DEFINE_GET_STAT_COUNTER(l2cache_write_hit,10,0);
DEFINE_GET_STAT_COUNTER(l2cache_write_miss,10,1);
DEFINE_GET_STAT_COUNTER(l2cache_read_hit,10,2);
DEFINE_GET_STAT_COUNTER(l2cache_read_miss,10,3);
DEFINE_GET_STAT_COUNTER(l2cache_evict,10,6);
DEFINE_GET_STAT_COUNTER(l2cache_set_tag_write,10,8);
DEFINE_GET_STAT_COUNTER(l2cache_set_tag_read,10,9);
DEFINE_GET_STAT_COUNTER(mem_byte_read,11,0);
DEFINE_GET_STAT_COUNTER(mem_byte_write,11,1);
DEFINE_GET_STAT_COUNTER(mem_hword_read,11,2);
DEFINE_GET_STAT_COUNTER(mem_hword_write,11,3);
DEFINE_GET_STAT_COUNTER(mem_word_read,11,4);
DEFINE_GET_STAT_COUNTER(mem_word_write,11,5);
DEFINE_GET_STAT_COUNTER(mem_dword_read,11,6);
DEFINE_GET_STAT_COUNTER(mem_dword_write,11,7);
DEFINE_GET_STAT_COUNTER(mem_cap_read,11,8);
DEFINE_GET_STAT_COUNTER(mem_cap_write,11,9);
DEFINE_GET_STAT_COUNTER(mem_cap_read_tag_set,11,10);
DEFINE_GET_STAT_COUNTER(mem_cap_write_tag_set,11,11);
DEFINE_GET_STAT_COUNTER(tagcache_write_hit,12,0);
DEFINE_GET_STAT_COUNTER(tagcache_write_miss,12,1);
DEFINE_GET_STAT_COUNTER(tagcache_read_hit,12,2);
DEFINE_GET_STAT_COUNTER(tagcache_read_miss,12,3);
DEFINE_GET_STAT_COUNTER(tagcache_evict,12,6);
DEFINE_GET_STAT_COUNTER(l2cachemaster_read_req,13,0);
DEFINE_GET_STAT_COUNTER(l2cachemaster_write_req,13,1);
DEFINE_GET_STAT_COUNTER(l2cachemaster_write_req_flit,13,2);
DEFINE_GET_STAT_COUNTER(l2cachemaster_read_rsp,13,3);
DEFINE_GET_STAT_COUNTER(l2cachemaster_read_rsp_flit,13,4);
DEFINE_GET_STAT_COUNTER(l2cachemaster_write_rsp,13,5);
DEFINE_GET_STAT_COUNTER(tagcachemaster_read_req,14,0);
DEFINE_GET_STAT_COUNTER(tagcachemaster_write_req,14,1);
DEFINE_GET_STAT_COUNTER(tagcachemaster_write_req_flit,14,2);
DEFINE_GET_STAT_COUNTER(tagcachemaster_read_rsp,14,3);
DEFINE_GET_STAT_COUNTER(tagcachemaster_read_rsp_flit,14,4);
DEFINE_GET_STAT_COUNTER(tagcachemaster_write_rsp,14,5);

// helper functions

// libstatcounters API
//////////////////////////////////////////////////////////////////////////////

// reset the hardware statcounters

int statcounters_sample (statcounters_bank_t * const cnt_bank)
{
	if (cnt_bank == 0)
		return -1;
	cnt_bank->icache[STATCOUNTERS_WRITE_HIT]              = get_icache_write_hit_count();
	cnt_bank->icache[STATCOUNTERS_WRITE_MISS]             = get_icache_write_miss_count();
	cnt_bank->icache[STATCOUNTERS_READ_HIT]               = get_icache_read_hit_count();
	cnt_bank->icache[STATCOUNTERS_READ_MISS]              = get_icache_read_miss_count();
	cnt_bank->icache[STATCOUNTERS_EVICT]                  = get_icache_evict_count();
	cnt_bank->dcache[STATCOUNTERS_WRITE_HIT]              = get_dcache_write_hit_count();
	cnt_bank->dcache[STATCOUNTERS_WRITE_MISS]             = get_dcache_write_miss_count();
	cnt_bank->dcache[STATCOUNTERS_READ_HIT]               = get_dcache_read_hit_count();
	cnt_bank->dcache[STATCOUNTERS_READ_MISS]              = get_dcache_read_miss_count();
	cnt_bank->dcache[STATCOUNTERS_EVICT]                  = get_dcache_evict_count();
	cnt_bank->dcache[STATCOUNTERS_SET_TAG_WRITE]          = get_dcache_set_tag_write_count();
	cnt_bank->dcache[STATCOUNTERS_SET_TAG_READ]           = get_dcache_set_tag_read_count();
	cnt_bank->l2cache[STATCOUNTERS_WRITE_HIT]             = get_l2cache_write_hit_count();
	cnt_bank->l2cache[STATCOUNTERS_WRITE_MISS]            = get_l2cache_write_miss_count();
	cnt_bank->l2cache[STATCOUNTERS_READ_HIT]              = get_l2cache_read_hit_count();
	cnt_bank->l2cache[STATCOUNTERS_READ_MISS]             = get_l2cache_read_miss_count();
	cnt_bank->l2cache[STATCOUNTERS_EVICT]                 = get_l2cache_evict_count();
	cnt_bank->l2cache[STATCOUNTERS_SET_TAG_WRITE]         = get_l2cache_set_tag_write_count();
	cnt_bank->l2cache[STATCOUNTERS_SET_TAG_READ]          = get_l2cache_set_tag_read_count();
	cnt_bank->l2cachemaster[STATCOUNTERS_READ_REQ]        = get_l2cachemaster_read_req_count();
	cnt_bank->l2cachemaster[STATCOUNTERS_WRITE_REQ]       = get_l2cachemaster_write_req_count();
	cnt_bank->l2cachemaster[STATCOUNTERS_WRITE_REQ_FLIT]  = get_l2cachemaster_write_req_flit_count();
	cnt_bank->l2cachemaster[STATCOUNTERS_READ_RSP]        = get_l2cachemaster_read_rsp_count();
	cnt_bank->l2cachemaster[STATCOUNTERS_READ_RSP_FLIT]   = get_l2cachemaster_read_rsp_flit_count();
	cnt_bank->l2cachemaster[STATCOUNTERS_WRITE_RSP]       = get_l2cachemaster_write_rsp_count();
	cnt_bank->tagcache[STATCOUNTERS_WRITE_HIT]            = get_tagcache_write_hit_count();
	cnt_bank->tagcache[STATCOUNTERS_WRITE_MISS]           = get_tagcache_write_miss_count();
	cnt_bank->tagcache[STATCOUNTERS_READ_HIT]             = get_tagcache_read_hit_count();
	cnt_bank->tagcache[STATCOUNTERS_READ_MISS]            = get_tagcache_read_miss_count();
	cnt_bank->tagcache[STATCOUNTERS_EVICT]                = get_tagcache_evict_count();
	cnt_bank->tagcachemaster[STATCOUNTERS_READ_REQ]       = get_tagcachemaster_read_req_count();
	cnt_bank->tagcachemaster[STATCOUNTERS_WRITE_REQ]      = get_tagcachemaster_write_req_count();
	cnt_bank->tagcachemaster[STATCOUNTERS_WRITE_REQ_FLIT] = get_tagcachemaster_write_req_flit_count();
	cnt_bank->tagcachemaster[STATCOUNTERS_READ_RSP]       = get_tagcachemaster_read_rsp_count();
	cnt_bank->tagcachemaster[STATCOUNTERS_READ_RSP_FLIT]  = get_tagcachemaster_read_rsp_flit_count();
	cnt_bank->tagcachemaster[STATCOUNTERS_WRITE_RSP]      = get_tagcachemaster_write_rsp_count();
	cnt_bank->mipsmem[STATCOUNTERS_BYTE_READ]             = get_mem_byte_read_count();
	cnt_bank->mipsmem[STATCOUNTERS_BYTE_WRITE]            = get_mem_byte_write_count();
	cnt_bank->mipsmem[STATCOUNTERS_HWORD_READ]            = get_mem_hword_read_count();
	cnt_bank->mipsmem[STATCOUNTERS_HWORD_WRITE]           = get_mem_hword_write_count();
	cnt_bank->mipsmem[STATCOUNTERS_WORD_READ]             = get_mem_word_read_count();
	cnt_bank->mipsmem[STATCOUNTERS_WORD_WRITE]            = get_mem_word_write_count();
	cnt_bank->mipsmem[STATCOUNTERS_DWORD_READ]            = get_mem_dword_read_count();
	cnt_bank->mipsmem[STATCOUNTERS_DWORD_WRITE]           = get_mem_dword_write_count();
	cnt_bank->mipsmem[STATCOUNTERS_CAP_READ]              = get_mem_cap_read_count();
	cnt_bank->mipsmem[STATCOUNTERS_CAP_WRITE]             = get_mem_cap_write_count();
	cnt_bank->mipsmem[STATCOUNTERS_CAP_READ_TAG_SET]      = get_mem_cap_read_tag_set_count();
	cnt_bank->mipsmem[STATCOUNTERS_CAP_WRITE_TAG_SET]     = get_mem_cap_write_tag_set_count();
	cnt_bank->dtlb_miss                                   = get_dtlb_miss_count();
	cnt_bank->itlb_miss                                   = get_itlb_miss_count();
	cnt_bank->inst                                        = get_inst_count();
	cnt_bank->cycle                                       = get_cycle_count();
	return 0;
}

int test(void) {
	statcounters_bank_t start_cnt;
	statcounters_sample(&start_cnt);
	return 0;
}
