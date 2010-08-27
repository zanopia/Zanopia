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

