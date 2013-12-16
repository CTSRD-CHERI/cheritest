/*-
 * Copyright (c) 2013 Michael Roe
 * All rights reserved.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "assert.h"

/*
 * Test that a C program can read a floating point value via a capability,
 *
 * To make sure that the floating point number gets as far as the FPU
 * (not just into an integer register) we do some arithmetic on it - summing
 * the values from 1 to 4.
 *
 * This test will succeed without attempting any floating point if it is
 * run on a CPU that does not have floating point hardware (as determined by
 * the CP0.Config1 register).
 */

/*
 * Read coprocessor 0 config1 register to find out if the CPU has hardware
 * floating point.
 */

static long config1;

static long get_config_reg()
{
unsigned long val;

  asm volatile ("dmfc0 %0, $16, 1" : "=r"(val));

  return val;
}

static float array[4] = {
    1.0,
    2.0,
    3.0,
    4.0
};

int test_body(void)
{
int i;
float total;
__capability float *fp;

    fp = (__capability float *) array;
    total = 0.0;
    for (i=0; i<4; i++)
    {
      total += *fp;
      fp++;
    }

    assert(total == 10.0);

    return 0;
}

int test(void)
{

  config1 = get_config_reg();
  if (config1 & 0x1)
    test_body();
  else
    assert(1);

  return 0;
}
