;C:\PACIFIC\INCLUDE\stdlib.h: 91: extern int atexit(void (*)(void));
;C:\PACIFIC\INCLUDE\stdlib.h: 95: extern void qsort(void *, size_t, size_t, int (*)(const void *, const void *));
;C:\PACIFIC\INCLUDE\stdlib.h: 96: extern void * bsearch(const void *, void *, size_t, size_t, int(*)(const void *, const void *));
;C:\PACIFIC\INCLUDE\stdlib.h: 91: extern int atexit(void (*)(void));
;C:\PACIFIC\INCLUDE\stdlib.h: 95: extern void qsort(void *, size_t, size_t, int (*)(const void *, const void *));
;C:\PACIFIC\INCLUDE\stdlib.h: 96: extern void * bsearch(const void *, void *, size_t, size_t, int(*)(const void *, const void *));
;mouse.h: 99: extern void eventhandler(int, void (*)(struct mousedata *));
	.globl	small_data
	.globl	small_code
	.psect	data,class=DATA
	.globl	__TICK_COUNT_
	.align	2
__TICK_COUNT_:
	.word	040006Ch&0ffffh
	.word	040h
	.globl	_initmouse
	.signat	_initmouse,26
	.psect	_TEXT,class=CODE
	.globl	_int86x
	.signat	_int86x,16442
	.globl	_int86
	.signat	_int86,12346
_initmouse:
	push	bp
	mov	bp,sp
	sub	sp,#018h
;MOUSE.C: 39: union REGS reg;
	mov	-24[bp],#03533h, word
;MOUSE.C: 43: int86x(0x21, &reg, &reg, &seg);
	lea	cx,-8[bp]
	push	cx
	lea	cx,-24[bp]
	push	cx
	lea	ax,-24[bp]
	mov	dx,#021h
	call	_int86x
;MOUSE.C: 44: if (reg.x.bx == 0 && seg.es == 0)
	cmp	-22[bp],#0, word
	brne	l15
	cmp	-8[bp],#0, word
	bre	L1
;MOUSE.C: 45: return -1;
l15:
;MOUSE.C: 46: reg.x.ax = 0;
	mov	-24[bp],#0, word
;MOUSE.C: 47: int86(0x33, &reg, &reg);
	lea	cx,-24[bp]
	push	cx
	lea	ax,-24[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 48: if (reg.x.ax == 0)
	cmp	-24[bp],#0, word
	brne	l16
L1:
;MOUSE.C: 49: return -1;
	mov	ax,#-1
	jmp	l14
l16:
;MOUSE.C: 50: return reg.x.bx;
	mov	ax,-22[bp]
;MOUSE.C: 51: }
l14:
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_shutdownmouse
	.signat	_shutdownmouse,24
	.globl	_eventhandler
	.signat	_eventhandler,8248
;MOUSE.C: 59: void
;MOUSE.C: 60: shutdownmouse(void)
;MOUSE.C: 61: {
_shutdownmouse:
;MOUSE.C: 62: eventhandler(0, ((void *)0));
	xor	ax,ax
	mov	dx,ax
	call	_eventhandler
;MOUSE.C: 63: }
	ret	#0
	.globl	_showcursor
	.signat	_showcursor,24
;MOUSE.C: 71: void
;MOUSE.C: 72: showcursor(void)
;MOUSE.C: 73: {
_showcursor:
	push	bp
	mov	bp,sp
	sub	sp,#010h
;MOUSE.C: 74: union REGS reg;
	mov	-16[bp],#1, word
;MOUSE.C: 77: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 78: }
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_hidecursor
	.signat	_hidecursor,24
;MOUSE.C: 86: void
;MOUSE.C: 87: hidecursor(void)
;MOUSE.C: 88: {
_hidecursor:
	push	bp
	mov	bp,sp
	sub	sp,#010h
;MOUSE.C: 89: union REGS reg;
	mov	-16[bp],#2, word
;MOUSE.C: 92: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 93: }
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_readmouse
	.signat	_readmouse,4152
;MOUSE.C: 101: void
;MOUSE.C: 102: readmouse(struct mousedata * mouse)
;MOUSE.C: 103: {
_readmouse:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _mouse loaded to di
	mov	di,dx
;MOUSE.C: 104: union REGS reg;
	mov	-16[bp],#3, word
;MOUSE.C: 107: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 108: mouse->timer = *_TICK_COUNT_;
	les	bx,__TICK_COUNT_&0FFFFh
	mov	ax,es:[bx]
	mov	cx,es:2[bx]
	mov	12[di],ax
	mov	14[di],cx
;MOUSE.C: 109: mouse->buttons = reg.x.bx;
	mov	cx,-14[bp]
	mov	4[di],cx
;MOUSE.C: 110: mouse->x = reg.x.cx;
	mov	cx,-12[bp]
	mov	2[di],cx
;MOUSE.C: 111: mouse->y = reg.x.dx;
	mov	cx,-10[bp]
	mov	[di],cx
;MOUSE.C: 112: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_setmousepos
	.signat	_setmousepos,8248
;MOUSE.C: 120: void
;MOUSE.C: 121: setmousepos(int row, int col)
;MOUSE.C: 122: {
_setmousepos:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _col loaded to bx
	mov	bx,ax
; _row loaded to di
	mov	di,dx
;MOUSE.C: 123: union REGS reg;
	mov	-12[bp],bx
;MOUSE.C: 126: reg.x.dx = row;
	mov	-10[bp],di
;MOUSE.C: 127: reg.x.ax = 4;
	mov	-16[bp],#4, word
;MOUSE.C: 128: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 129: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_getpressinfo
	.signat	_getpressinfo,8248
;MOUSE.C: 137: void
;MOUSE.C: 138: getpressinfo(int button, struct mousedata * mouse)
;MOUSE.C: 139: {
_getpressinfo:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _mouse loaded to di
	mov	di,ax
; _button loaded to bx
	mov	bx,dx
;MOUSE.C: 140: union REGS reg;
	mov	-16[bp],#5, word
;MOUSE.C: 143: reg.x.bx = button;
	mov	-14[bp],bx
;MOUSE.C: 144: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 145: mouse->timer = *_TICK_COUNT_;
	les	bx,__TICK_COUNT_&0FFFFh
	mov	ax,es:[bx]
	mov	cx,es:2[bx]
	mov	12[di],ax
	mov	14[di],cx
;MOUSE.C: 146: mouse->buttons = reg.x.ax;
	mov	cx,-16[bp]
	mov	4[di],cx
;MOUSE.C: 147: mouse->count = reg.x.bx;
	mov	cx,-14[bp]
	mov	6[di],cx
;MOUSE.C: 148: mouse->x = reg.x.cx;
	mov	cx,-12[bp]
	mov	2[di],cx
;MOUSE.C: 149: mouse->y = reg.x.dx;
	mov	cx,-10[bp]
	mov	[di],cx
;MOUSE.C: 150: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_getreleaseinfo
	.signat	_getreleaseinfo,8248
;MOUSE.C: 158: void
;MOUSE.C: 159: getreleaseinfo(int button, struct mousedata * mouse)
;MOUSE.C: 160: {
_getreleaseinfo:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _mouse loaded to di
	mov	di,ax
; _button loaded to bx
	mov	bx,dx
;MOUSE.C: 161: union REGS reg;
	mov	-16[bp],#6, word
;MOUSE.C: 164: reg.x.bx = button;
	mov	-14[bp],bx
;MOUSE.C: 165: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 166: mouse->timer = *_TICK_COUNT_;
	les	bx,__TICK_COUNT_&0FFFFh
	mov	ax,es:[bx]
	mov	cx,es:2[bx]
	mov	12[di],ax
	mov	14[di],cx
;MOUSE.C: 167: mouse->buttons = reg.x.ax;
	mov	cx,-16[bp]
	mov	4[di],cx
;MOUSE.C: 168: mouse->count = reg.x.bx;
	mov	cx,-14[bp]
	mov	6[di],cx
;MOUSE.C: 169: mouse->x = reg.x.cx;
	mov	cx,-12[bp]
	mov	2[di],cx
;MOUSE.C: 170: mouse->y = reg.x.dx;
	mov	cx,-10[bp]
	mov	[di],cx
;MOUSE.C: 171: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_sethlimits
	.signat	_sethlimits,8248
;MOUSE.C: 179: void
;MOUSE.C: 180: sethlimits(int min, int max)
;MOUSE.C: 181: {
_sethlimits:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _max loaded to bx
	mov	bx,ax
; _min loaded to di
	mov	di,dx
;MOUSE.C: 182: union REGS reg;
	mov	-16[bp],#7, word
;MOUSE.C: 185: reg.x.cx = min;
	mov	-12[bp],di
;MOUSE.C: 186: reg.x.dx = max;
	mov	-10[bp],bx
;MOUSE.C: 187: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 188: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_setvlimits
	.signat	_setvlimits,8248
;MOUSE.C: 196: void
;MOUSE.C: 197: setvlimits(int min, int max)
;MOUSE.C: 198: {
_setvlimits:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _max loaded to di
	mov	di,ax
; _min loaded to bx
	mov	bx,dx
;MOUSE.C: 199: union REGS reg;
	mov	-16[bp],#8, word
;MOUSE.C: 202: reg.x.cx = min;
	mov	-12[bp],bx
;MOUSE.C: 203: reg.x.dx = max;
	mov	-10[bp],di
;MOUSE.C: 204: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 205: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_setgrcursor
	.signat	_setgrcursor,4152
;MOUSE.C: 213: void
;MOUSE.C: 214: setgrcursor(struct graphic_cursor * cursor)
;MOUSE.C: 215: {
_setgrcursor:
	push	bp
	mov	bp,sp
	sub	sp,#018h
	push	si
; _cursor loaded to si
	mov	si,dx
;MOUSE.C: 216: union REGS reg;
	mov	-24[bp],#9, word
;MOUSE.C: 220: reg.x.bx = cursor->hotspot_x;
	mov	cx,040h[si]
	mov	-22[bp],cx
;MOUSE.C: 221: reg.x.cx = cursor->hotspot_y;
	mov	cx,042h[si]
	mov	-20[bp],cx
;MOUSE.C: 222: reg.x.dx = ((unsigned short)(cursor));
	mov	-18[bp],si
;MOUSE.C: 223: seg.es = (((long)(far void *)(cursor)) >> 16);
	mov	dx,ds
	mov	ax,dx
	mov	-8[bp],ax
;MOUSE.C: 224: int86x(0x33, &reg, &reg, &seg);
	lea	cx,-8[bp]
	push	cx
	lea	cx,-24[bp]
	push	cx
	lea	ax,-24[bp]
	mov	dx,#033h
	call	_int86x
;MOUSE.C: 225: }
	pop	si
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_setcursor
	.signat	_setcursor,20536
;MOUSE.C: 235: void
;MOUSE.C: 236: setcursor(int type, unsigned int smask_char, unsigned int smask_attr,
;MOUSE.C: 237: unsigned int cmask_char, unsigned int cmask_attr)
;MOUSE.C: 238: {
_setcursor:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
	push	si
; _smask_char loaded to si
	mov	si,ax
; _type loaded to di
	mov	di,dx
;MOUSE.C: 239: union REGS reg;
	mov	-16[bp],#10, word
;MOUSE.C: 242: reg.x.bx = type;
	mov	-14[bp],di
;MOUSE.C: 243: reg.x.cx = (smask_char & 0xFF) | (smask_attr << 8);
	mov	bx,4[bp]
	mov	bh,bl
	sub	bl,bl
	mov	cx,si
	and	cx,#0FFh
	or	cx,bx
	mov	-12[bp],cx
;MOUSE.C: 244: reg.x.dx = (cmask_char & 0xFF) | (cmask_attr << 8);
	mov	bx,8[bp]
	mov	bh,bl
	sub	bl,bl
	mov	cx,6[bp]
	and	cx,#0FFh
	or	cx,bx
	mov	-10[bp],cx
;MOUSE.C: 245: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 246: }
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	ret	#6
	.globl	_readcounters
	.signat	_readcounters,4152
;MOUSE.C: 254: void
;MOUSE.C: 255: readcounters(struct mousedata * mouse)
;MOUSE.C: 256: {
_readcounters:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _mouse loaded to di
	mov	di,dx
;MOUSE.C: 257: union REGS reg;
	mov	-16[bp],#11, word
;MOUSE.C: 260: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 261: mouse->x = reg.x.cx;
	mov	cx,-12[bp]
	mov	2[di],cx
;MOUSE.C: 262: mouse->y = reg.x.dx;
	mov	cx,-10[bp]
	mov	[di],cx
;MOUSE.C: 263: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_setpixelratio
	.signat	_setpixelratio,8248
;MOUSE.C: 271: void
;MOUSE.C: 272: setpixelratio(int vertical, int horizontal)
;MOUSE.C: 273: {
_setpixelratio:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _horizontal loaded to di
	mov	di,ax
; _vertical loaded to bx
	mov	bx,dx
;MOUSE.C: 274: union REGS reg;
	mov	-16[bp],#15, word
;MOUSE.C: 277: reg.x.cx = horizontal;
	mov	-12[bp],di
;MOUSE.C: 278: reg.x.dx = vertical;
	mov	-10[bp],bx
;MOUSE.C: 279: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 280: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_conditionalhide
	.signat	_conditionalhide,4152
;MOUSE.C: 288: void
;MOUSE.C: 289: conditionalhide(struct boundsrect * rect)
;MOUSE.C: 290: {
_conditionalhide:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _rect loaded to di
	mov	di,dx
;MOUSE.C: 291: union REGS reg;
	mov	-16[bp],#010h, word
;MOUSE.C: 294: reg.x.cx = rect->left;
	mov	cx,2[di]
	mov	-12[bp],cx
;MOUSE.C: 295: reg.x.dx = rect->top;
	mov	cx,[di]
	mov	-10[bp],cx
;MOUSE.C: 296: reg.x.si = rect->right;
	mov	cx,6[di]
	mov	-8[bp],cx
;MOUSE.C: 297: reg.x.di = rect->bottom;
	mov	cx,4[di]
	mov	-6[bp],cx
;MOUSE.C: 298: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 299: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_speedthreshold
	.signat	_speedthreshold,4152
;MOUSE.C: 308: void
;MOUSE.C: 309: speedthreshold(int threshold)
;MOUSE.C: 310: {
_speedthreshold:
	push	bp
	mov	bp,sp
	sub	sp,#010h
; _threshold loaded to bx
	mov	bx,dx
;MOUSE.C: 311: union REGS reg;
	mov	-16[bp],#013h, word
;MOUSE.C: 314: reg.x.dx = threshold;
	mov	-10[bp],bx
;MOUSE.C: 315: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 316: }
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_setsensitivity
	.signat	_setsensitivity,4152
;MOUSE.C: 325: void
;MOUSE.C: 326: setsensitivity(struct sensitivity * se)
;MOUSE.C: 327: {
_setsensitivity:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _se loaded to di
	mov	di,dx
;MOUSE.C: 328: union REGS reg;
	mov	-16[bp],#01Ah, word
;MOUSE.C: 331: reg.x.bx = se->horizontal;
	mov	cx,[di]
	mov	-14[bp],cx
;MOUSE.C: 332: reg.x.cx = se->vertical;
	mov	cx,2[di]
	mov	-12[bp],cx
;MOUSE.C: 333: reg.x.dx = se->threshold;
	mov	cx,4[di]
	mov	-10[bp],cx
;MOUSE.C: 334: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 335: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_getsensitivity
	.signat	_getsensitivity,4152
;MOUSE.C: 344: void
;MOUSE.C: 345: getsensitivity(struct sensitivity * se)
;MOUSE.C: 346: {
_getsensitivity:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _se loaded to di
	mov	di,dx
;MOUSE.C: 347: union REGS reg;
	mov	-16[bp],#01Bh, word
;MOUSE.C: 350: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 351: se->horizontal = reg.x.bx;
	mov	cx,-14[bp]
	mov	[di],cx
;MOUSE.C: 352: se->vertical = reg.x.cx;
	mov	cx,-12[bp]
	mov	2[di],cx
;MOUSE.C: 353: se->threshold = reg.x.dx;
	mov	cx,-10[bp]
	mov	4[di],cx
;MOUSE.C: 354: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_getstoragesize
	.signat	_getstoragesize,26
;MOUSE.C: 363: size_t
;MOUSE.C: 364: getstoragesize(void)
;MOUSE.C: 365: {
_getstoragesize:
	push	bp
	mov	bp,sp
	sub	sp,#010h
;MOUSE.C: 366: union REGS reg;
	mov	-16[bp],#015h, word
;MOUSE.C: 369: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 370: return reg.x.bx;
	mov	ax,-14[bp]
;MOUSE.C: 371: }
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_savestate
	.signat	_savestate,4152
;MOUSE.C: 379: void
;MOUSE.C: 380: savestate(void * buffer)
;MOUSE.C: 381: {
_savestate:
	push	bp
	mov	bp,sp
	sub	sp,#018h
; _buffer loaded to bx
	mov	bx,dx
;MOUSE.C: 382: union REGS reg;
	mov	-24[bp],#016h, word
;MOUSE.C: 386: reg.x.dx = ((unsigned short)(buffer));
	mov	-18[bp],bx
;MOUSE.C: 387: seg.es = (((long)(far void *)(buffer)) >> 16);
	mov	dx,ds
	mov	ax,dx
	mov	-8[bp],ax
;MOUSE.C: 388: int86x(0x33, &reg, &reg, &seg);
	lea	cx,-8[bp]
	push	cx
	lea	cx,-24[bp]
	push	cx
	lea	ax,-24[bp]
	mov	dx,#033h
	call	_int86x
;MOUSE.C: 389: }
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_restorestate
	.signat	_restorestate,4152
;MOUSE.C: 397: void
;MOUSE.C: 398: restorestate(void * buffer)
;MOUSE.C: 399: {
_restorestate:
	push	bp
	mov	bp,sp
	sub	sp,#018h
; _buffer loaded to bx
	mov	bx,dx
;MOUSE.C: 400: union REGS reg;
	mov	-24[bp],#017h, word
;MOUSE.C: 404: reg.x.dx = ((unsigned short)(buffer));
	mov	-18[bp],bx
;MOUSE.C: 405: seg.es = (((long)(far void *)(buffer)) >> 16);
	mov	dx,ds
	mov	ax,dx
	mov	-8[bp],ax
;MOUSE.C: 406: int86x(0x33, &reg, &reg, &seg);
	lea	cx,-8[bp]
	push	cx
	lea	cx,-24[bp]
	push	cx
	lea	ax,-24[bp]
	mov	dx,#033h
	call	_int86x
;MOUSE.C: 407: }
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_savemouse
	.signat	_savemouse,26
	.globl	_free
	.signat	_free,4152
	.globl	_malloc
	.signat	_malloc,4154
;MOUSE.C: 424: static size_t _m_savesize_;
;MOUSE.C: 425: static void * _m_saveptr_;
;MOUSE.C: 427: int
;MOUSE.C: 428: savemouse(void)
;MOUSE.C: 429: {
_savemouse:
;MOUSE.C: 430: if (_m_saveptr_) {
	cmp	__m_saveptr_&0FFFFh,#0, word
	bre	l38
;MOUSE.C: 431: if (_m_savesize_ < getstoragesize()) {
	call	_getstoragesize
	mov	cx,__m_savesize_&0FFFFh
	cmp	cx,ax
	brnb	l38
;MOUSE.C: 432: free(_m_saveptr_);
	mov	dx,__m_saveptr_&0FFFFh
	call	_free
;MOUSE.C: 433: _m_saveptr_ = ((void *)0);
	mov	__m_saveptr_&0FFFFh,#0, word
;MOUSE.C: 434: }
l38:
;MOUSE.C: 436: if (!_m_saveptr_) {
	cmp	__m_saveptr_&0FFFFh,#0, word
	brne	l40
;MOUSE.C: 437: _m_savesize_ = getstoragesize();
	call	_getstoragesize
	mov	__m_savesize_&0FFFFh,ax
;MOUSE.C: 438: _m_saveptr_ = malloc(_m_savesize_);
	mov	dx,__m_savesize_&0FFFFh
	call	_malloc
	mov	__m_saveptr_&0FFFFh,ax
;MOUSE.C: 439: if (!_m_saveptr_) {
	cmp	__m_saveptr_&0FFFFh,#0, word
	brne	l40
;MOUSE.C: 440: return 0;
	xor	ax,ax
;MOUSE.C: 445: }
l37:
	ret	#0
l40:
;MOUSE.C: 443: savestate(_m_saveptr_);
	mov	dx,__m_saveptr_&0FFFFh
	call	_savestate
;MOUSE.C: 444: return 1;
	mov	ax,#1
	jmp	l37
	.globl	_restoremouse
	.signat	_restoremouse,26
;MOUSE.C: 456: int
;MOUSE.C: 457: restoremouse(void)
;MOUSE.C: 458: {
_restoremouse:
;MOUSE.C: 459: if (_m_saveptr_) {
	cmp	__m_saveptr_&0FFFFh,#0, word
	bre	l43
;MOUSE.C: 460: restorestate(_m_saveptr_);
	mov	dx,__m_saveptr_&0FFFFh
	call	_restorestate
;MOUSE.C: 461: return 1;
	mov	ax,#1
;MOUSE.C: 465: }
l42:
	ret	#0
l43:
;MOUSE.C: 463: return 0;
	xor	ax,ax
	jmp	l42
	.globl	_getmouseinfo
	.signat	_getmouseinfo,4152
;MOUSE.C: 476: void
;MOUSE.C: 477: getmouseinfo(struct mouseinfo * minfo)
;MOUSE.C: 478: {
_getmouseinfo:
	push	bp
	mov	bp,sp
	sub	sp,#010h
	push	di
; _minfo loaded to di
	mov	di,dx
;MOUSE.C: 479: union REGS reg;
	mov	-16[bp],#024h, word
;MOUSE.C: 482: int86(0x33, &reg, &reg);
	lea	cx,-16[bp]
	push	cx
	lea	ax,-16[bp]
	mov	dx,#033h
	call	_int86
;MOUSE.C: 483: minfo->majorver = reg.h.bh;
	mov	ch,-13[bp]
	mov	1[di],ch
;MOUSE.C: 484: minfo->minorver = reg.h.bl;
	mov	ch,-14[bp]
	mov	[di],ch
;MOUSE.C: 485: minfo->mousetype = reg.h.ch;
	mov	ch,-11[bp]
	mov	3[di],ch
;MOUSE.C: 486: minfo->irqnumber = reg.h.cl;
	mov	ch,-12[bp]
	mov	2[di],ch
;MOUSE.C: 487: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	_keymodbits
	.signat	_keymodbits,26
;MOUSE.C: 495: unsigned int
;MOUSE.C: 496: keymodbits(void)
;MOUSE.C: 497: {
_keymodbits:
;MOUSE.C: 498: return KBSTATUS;
	mov	cx,#040h
	mov	es,cx
	mov	ax,es:017h
;MOUSE.C: 499: }
	ret	#0
	.globl	__asm_event_glue
	.signat	__asm_event_glue,24
;MOUSE.C: 520: extern void _asm_event_glue(void);
;MOUSE.C: 521: static void (*user_handler)(struct mousedata *);
;MOUSE.C: 523: void
;MOUSE.C: 524: eventhandler(int eventbits, void (*handler)(struct mousedata *))
;MOUSE.C: 525: {
_eventhandler:
	push	bp
	mov	bp,sp
	sub	sp,#018h
	push	di
; _handler loaded to di
	mov	di,ax
; _eventbits loaded to bx
	mov	bx,dx
;MOUSE.C: 526: union REGS reg;
	mov	_user_handler&0FFFFh,di
;MOUSE.C: 530: reg.x.ax = 12;
	mov	-24[bp],#12, word
;MOUSE.C: 531: reg.x.cx = (eventbits != -1)? eventbits : 0;
	cmp	bx,#-1
	brne	u53
	xor	ax,ax
	jmp	u54
u53:
	mov	ax,bx
u54:
	mov	-20[bp],ax
;MOUSE.C: 532: reg.x.dx = ((unsigned short)(_asm_event_glue));
	mov	-18[bp],#__asm_event_glue, word
;MOUSE.C: 533: seg.es = (((long)(far void (*)(void))(_asm_event_glue)) >> 16);
	mov	dx,cs
	mov	ax,dx
	mov	-8[bp],ax
;MOUSE.C: 534: int86x(0x33, &reg, &reg, &seg);
	lea	cx,-8[bp]
	push	cx
	lea	cx,-24[bp]
	push	cx
	lea	ax,-24[bp]
	mov	dx,#033h
	call	_int86x
;MOUSE.C: 535: }
	pop	di
	mov	sp,bp
	pop	bp
	ret	#0
	.globl	__c_event_glue_
	.signat	__c_event_glue_,16440
;MOUSE.C: 556: void
;MOUSE.C: 557: _c_event_glue_(unsigned short DX, unsigned short AX, unsigned short BX, unsigned short CX)
;MOUSE.C: 558: {
__c_event_glue_:
	push	bp
	mov	bp,sp
	push	di
; _AX loaded to di
	mov	di,ax
;MOUSE.C: 559: static struct mousedata mouse;
	cmp	_user_handler&0FFFFh,#0, word
	bre	l48
;MOUSE.C: 562: mouse.event = AX;
	mov	(F451+8)&0FFFFh,di
;MOUSE.C: 563: mouse.buttons = BX;
	mov	cx,4[bp]
	mov	(F451+4)&0FFFFh,cx
;MOUSE.C: 564: mouse.x = CX;
	mov	cx,6[bp]
	mov	(F451+2)&0FFFFh,cx
;MOUSE.C: 565: mouse.y = DX;
	mov	F451&0FFFFh,dx
;MOUSE.C: 566: mouse.count = 0;
	mov	(F451+6)&0FFFFh,#0, word
;MOUSE.C: 567: mouse.keymods = KBSTATUS;
	mov	cx,#040h
	mov	es,cx
	mov	cx,es:017h
	mov	(F451+10)&0FFFFh,cx
;MOUSE.C: 568: mouse.timer = *_TICK_COUNT_;
	les	bx,__TICK_COUNT_&0FFFFh
	mov	ax,es:[bx]
	mov	cx,es:2[bx]
	mov	(F451+12)&0FFFFh,ax
	mov	(F451+14)&0FFFFh,cx
;MOUSE.C: 569: (*user_handler)(&mouse);
	mov	dx,#F451
	call	[_user_handler]
;MOUSE.C: 570: }
l48:
	pop	di
	pop	bp
	ret	#4
	.psect	lbss,local,reloc=16,size=65535,class=LBSS
_KBSTATUS	equ	4194327
	.psect	bss,class=BSS
	.align	2
__m_saveptr_:
	.blkb	2
	.align	2
__m_savesize_:
	.blkb	2
	.align	2
_user_handler:
	.blkb	2
	.align	2
F451:
	.blkb	16
	.psect	_TEXT
# 586 "MOUSE.C"
  .psect bss,class=BSS ;#
  .align 2 ;#
; ;#
; Scratch pad values used by event glue code ;#
; ;#
# 591 "MOUSE.C"
  .globl __Lbss ;#
__old_ss: .blkb 2 ;#
__old_sp: .blkb 2 ;#
__old_ds: .blkb 2 ;#
__old_es: .blkb 2 ;#
 ;#
# 599 "MOUSE.C"
    .blkb 256 ;#
__glue_stack: ;#
; ;#
# 602 "MOUSE.C"
 ;#
  .psect _TEXT,class=CODE,reloc=16,size=65535 ;#
 ;#
# 607 "MOUSE.C"
    .align 16 ;#
__asm_event_glue: ;#
  PUSHF ;keep current flag state ;#
  CLI ;ints off for the duration ;#
  CLD ;direction forwards ;#
  PUSH AX ;keep event bits ;#
  PUSH DS ;and driver DS ;#
  MOV AX,#seg(__Lbss) ;#
  MOV DS,AX ;setup user DS ;#
  POP __old_ds ;#
  MOV __old_es,ES ;#
  MOV __old_ss,SS ;#
  MOV __old_sp,SP ;keep driver stack ;#
  MOV ES,__old_ss ;ES indexes old stack ;#
  MOV AX,#seg(__glue_stack) ;#
  MOV SS,AX ;#
  MOV SP,#__glue_stack ;setup our own stack ;#
  PUSH CX ;#
  PUSH BX ;#
  MOV BX,__old_sp ;#
  MOV AX,ES:[BX] ;get driver AX value ;#
 ;#
  CALL __c_event_glue_ ;#
 ;#
# 633 "MOUSE.C"
    MOV SS,__old_ss ;get driver SS ;#
  MOV SP,__old_sp ;get driver SP ;#
  MOV ES,__old_es ;get driver ES ;#
  MOV DS,__old_ds ;get driver DS ;#
  POP AX ;#
  POPF ;#
  RETF ;#
	.end
