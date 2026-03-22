#ifndef FGL_H
#define FGL_H

#ifdef __cplusplus
extern "C"
{
#endif

	typedef struct FglContext FglContext;

	FglContext *fglCreateContext(void);
	void fglDestroyContext(FglContext *ctx);

#ifdef __cplusplus
}
#endif

#endif
