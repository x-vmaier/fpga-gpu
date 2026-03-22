#include <fgl.h>

int main(void)
{
	FglContext *ctx = fglCreateContext();
	fglDestroyContext(ctx);
	return 0;
}
