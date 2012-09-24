/*-
 * Copyright (c) 2012 David Chisnall
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

#if !defined(NAME) || !defined(TYPE)
#error Define NAME and TYPE before including this file
#endif

#define REALLY_PREFIX_SUFFIX(x,y) x ## y
#define PREFIX_SUFFIX(x, y) REALLY_PREFIX_SUFFIX(x, y)
#define PREFIX(x) PREFIX_SUFFIX(NAME, x)

static TYPE PREFIX(_data)[] = {1, 2, 3, 4, 5, 6, 7, 8};

int PREFIX(_test)(void)
{
  __capability TYPE *datacp = (__capability TYPE*)PREFIX(_data);

  for (int i=0; i<(sizeof(PREFIX(_data))/sizeof(*PREFIX(_data))); i++)
  {
    assert(datacp[i] == PREFIX(_data)[i]);
    PREFIX(_data)[i] = i * 42;
    assert(datacp[i] == PREFIX(_data)[i]);
    assert(datacp[i] == (TYPE)(i * 42));
    datacp[i] = 102442 * i;
    assert(datacp[i] == PREFIX(_data)[i]);
    assert(PREFIX(_data)[i] == (TYPE)(i * 102442));
  }

  return 0;
}
#undef NAME
#undef TYPE
