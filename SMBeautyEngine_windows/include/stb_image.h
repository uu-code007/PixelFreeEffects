#ifndef STB_IMAGE_H
#define STB_IMAGE_H

// stb_image.h接口声明
extern unsigned char *stbio_load(char const *filename, int *x, int *y, int *channels_in_file, int desired_channels);
extern void stbio_image_free(void *retval_from_stbio_load);
extern void stbio_set_flip_vertically_on_load(int flag_true_if_should_flip);

#endif // STB_IMAGE_H 