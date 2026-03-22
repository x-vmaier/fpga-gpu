#include "fgl.h"
#include <ftd2xx.h>
#include <stdlib.h>
#include <stdint.h>

struct FglContext
{
	FT_HANDLE uart;
};

FglContext *fglCreateContext(void)
{
	FglContext *ctx = malloc(sizeof(FglContext));
	if (!ctx) return NULL;

	return ctx;
}

void fglDestroyContext(FglContext *ctx)
{
	if (!ctx) return;
	free(ctx);
}
