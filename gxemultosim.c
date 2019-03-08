/*-
 * Copyright (c) 2019 Michael Roe
 * All rights reserved.
 *
 * This software was developed by the University of Cambridge Computer
 * Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
 * project, funded by EPSRC grant EP/K008528/1.
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static char *reg_names[] = {
  "at = 0x",
  "v0 = 0x",
  "v1 = 0x",
  "a0 = 0x",
  "a1 = 0x",
  "a2 = 0x",
  "a3 = 0x",
  "t0 = 0x",
  "t1 = 0x",
  "t2 = 0x",
  "t3 = 0x",
  "t4 = 0x",
  "t5 = 0x",
  "t6 = 0x",
  "t7 = 0x"
};


int main(int argc, char **argv)
{
unsigned long long reg[32];
unsigned long long v;
unsigned long long pc;
int i;
int j;
char buff[80];
char *cp;

  pc = 0;

  for (i=0; i<32; i++)
    reg[i] = 0;

  while (fgets(buff, sizeof(buff), stdin) != NULL)
  {
    printf("%s", buff);
    if (strncmp(buff, "cpu0:", 5) == 0)
    {
      cp = buff+5;
      while (*cp == ' ')
        cp++;
      if (strncmp(cp, "pc = 0x", 7) == 0)
      {
        pc = strtoull(cp+7, NULL, 16);
      }
      else if (strncmp(cp, "s0 = 0x", 7) == 0)
      {
        reg[16] = strtoull(cp+7, NULL, 16);
      }
      else
      {
        for (j=0; j<15; j++)
          if (strncmp(cp, reg_names[j], 7) == 0)
            {
	      v = strtoull(cp+7, NULL, 16);
	      reg[j + 1] = v;
	      cp = strstr(cp + 7, "0x");
	      if (cp)
              {
	        v = strtoull(cp + 2, NULL, 16);
	        reg[j + 17] = v;
              }
            }
      }
    }  
  }
  printf("======   Registers   ======\n");
  printf("DEBUG MIPS COREID 0\n");
  printf("DEBUG MIPS PC 0x%016llx\n", pc);
  for (i=0;i<32;i++)
    printf("DEBUG MIPS REG %2d 0x%016llx\n", i, reg[i]);

  return 0;
}

