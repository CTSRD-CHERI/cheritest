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

/*
 * xmlcat.c
 * Concatenate together several JUnit XML files
 */

#include <stdio.h>
#include <libxml/xmlreader.h>

static void print_children(xmlNode *node);

static void processNode(xmlTextReaderPtr reader)
{
const xmlChar *name;

  name = xmlTextReaderConstName(reader);
  if (name != NULL)
    printf("%s\n", name);
}

static void print_attributes(xmlAttr *attr)
{
  while (attr)
  {
    if (attr->name)
    {
      printf("%s", attr->name);
      if (attr->children && attr->children->content)
        printf("= %s", attr->children->content);
      printf("\n");
    } 
#if 0
    if (attr->children)
      print_children(attr->children);
#endif
    attr = attr->next;
  }
}

static void print_children(xmlNode *node)
{
  while (node)
  {
    switch(node->type)
    {
      case XML_ELEMENT_NODE:
        printf("%s\n", node->name);
        break;
      case XML_ATTRIBUTE_NODE:
        printf("attribute\n");
        break;
      case XML_TEXT_NODE:
        printf("text\n");
        break;
      default:
        printf("type %d\n", node->type);
        break;
    }

    print_attributes(node->properties);

    if (node->content)
      printf("content = %s\n", node->content);

    node = node->next;
  }
}

int main(int argc, char **argv)
{
xmlDoc *doc;
xmlNode *root;
xmlTextReaderPtr reader;
xmlAttr *attr;
int i;
int rc;
int tests = 0;
int errors = 0;
int failures = 0;
int skip = 0;

  for (i=1; i<argc; i++)
  {
    doc = xmlReadFile(argv[i], NULL, 0);

    if (doc == NULL)
    {
      fprintf(stderr, "Failed to open %s\n", argv[i]);
      return -1;
    }
    root = xmlDocGetRootElement(doc);
    printf("%s\n", root->name);
    attr = root->properties;
    while (attr)
    {
      if (strcmp(attr->name, "tests") == 0)
      {
        if (attr->children && attr->children->content)
          tests += atoi(attr->children->content);
      }
      else if (strcmp(attr->name, "errors") == 0)
      {
        if (attr->children && attr->children->content)
          errors += atoi(attr->children->content);
      }
      else if (strcmp(attr->name, "failures") == 0)
      {
        if (attr->children && attr->children->content)
          failures += atoi(attr->children->content);
      }
      else if (strcmp(attr->name, "skip") == 0)
      {
        if (attr->children && attr->children->content)
          skip += atoi(attr->children->content);
      }
      attr = attr->next;
    }
    xmlFreeDoc(doc);
  }

  printf("tests = %d\n", tests);
  printf("failures = %d\n", failures);
  printf("errors = %d\n", errors);
  printf("skip = %d\n", skip);

  return 0;
}
