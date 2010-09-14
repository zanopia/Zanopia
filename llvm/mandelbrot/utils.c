/* @GiorgioRegni - twitter

* Copyright 2010 Scality. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
* 
*    2. Redistributions in binary form must reproduce the above copyright notice, this list
*       of conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY Scality ``AS IS'' AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Scality OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES*  LOSS OF USE, DATA, OR PROFITS*  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Scality.
*/

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include "bmpfile.h"

#define PALETE_NUM_COLORS 256

void write_bmp(unsigned char *img, int width, int height) {
  bmpfile_t *bmp;
  int i, j;
  rgb_pixel_t palette[PALETE_NUM_COLORS] = {0};

  if ((bmp = bmp_create(width, height, 32)) == NULL) {
    printf("Could not create bitmap");
    exit(-1);
  }

  for (i=1;i<PALETE_NUM_COLORS/2;i++) {
    rgb_pixel_t *p = &palette[i];
    p->red = (int) (0XFF * (PALETE_NUM_COLORS/2.0+(double)i)/PALETE_NUM_COLORS);;
    p->green = 0X99;
    p->blue = 0X33;
  }

   for (;i<PALETE_NUM_COLORS;i++) {
    rgb_pixel_t *p = &palette[i];
    p->green = (int) (0XFF * (PALETE_NUM_COLORS/2.0+(double)i)/PALETE_NUM_COLORS);;
    p->red = 0X99;
    p->blue = 0X66;
  }

  for (j = 0; j < height; ++j) {
    for (i = 0; i < width; ++i) {
      int index = j*width+i;
      int c = img[index];

      bmp_set_pixel(bmp, i, j, palette[c % PALETE_NUM_COLORS]);
    }
  }
  bmp_save(bmp, "image.bmp");
  bmp_destroy(bmp);
}

