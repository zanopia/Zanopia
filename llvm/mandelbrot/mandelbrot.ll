; ModuleID = 'mandelbrot'

; Constants

; Various printf format for debugging purposes
@"print_i32" = internal constant [4 x i8] c"%d\0A\00"
@"print_double" = internal constant [5 x i8] c"%lf\0A\00" 
@"print_point" = internal constant [11 x i8] c"(%lf,%lf)\0A\00" 
@"print_point_color" = internal constant [14 x i8] c"(%lf,%lf,%d)\0A\00" 
@"print_color_i8" = internal constant [2 x i8] c"%c" 

; Mandelbrot fractal constant, play with it to generate new 
@MAXITER = internal constant i32 200
@ESCAPE = internal constant double 4.0
@XC = internal constant double -0.10894500736830963
@YC = internal constant double -0.8955496975621973
@ZOOM = internal constant double 0.1
@W  = internal constant i32 2048
@H  = internal constant i32 2048

; Entire image buffer in memory
@IMG = global [2048 x [2048 x i8]] zeroinitializer

; Externals
declare i32 @printf(i8*, ...)
declare void @write_bmp(i8* %img, i32 %width, i32 %height) nounwind

; function mand
; return # mandelbrot iterations for 1 point, (%re0, %im0), with %max iteration maximum
; Here's the formula
; ... TODO
define double @mand(double %re0, double %im0, i32 %max) {
       ;  variable definition
       %t.addr = alloca i32
       %re.addr = alloca double
       %im.addr = alloca double
       %z.addr = alloca double

       ; setup initial values
       store double %re0, double* %re.addr
       store double %im0, double* %im.addr
 
       ; loop t=0; t<max
       store i32 0, i32* %t.addr
       br label %loop_over_t

loop_over_t:
	%t = load i32* %t.addr
	; uncomment to debug t (loop counter)
	;%1 = call i32 (i8*, ...)* @printf(i8* getelementptr ([4 x i8]* @"print_i32", i32 0, i32 0), i32 %t)

	; compute re^2
	%re  = load double* %re.addr
	%im  = load double* %im.addr
	%re_re = mul double %re, %re
	%im_im = mul double %im, %im

	; compute z & compare with ESCAPE
	%z = add double %re_re, %im_im
	%escape = load double* @ESCAPE
	%conf_z_gt_escape = fcmp ogt double %z, %escape
	br i1 %conf_z_gt_escape, label %escape_reached, label %continue ; z > ESCAPE

continue:
	; increment t and loop
	%tp1 = add i32 1, %t
	store i32 %tp1, i32* %t.addr
	%cond_max_loop_reached = icmp eq i32 %tp1, %max
	br i1 %cond_max_loop_reached, label %max_reached, label %setup_next_loop ; loop if t < max

setup_next_loop:
	; calculate new re and im
	; re = re_re - im_im + re0
	%re_temp1 = sub double %re_re, %im_im
	%re_temp2 = add double %re_temp1, %re0
	store double %re_temp2, double* %re.addr
	; im = 2 * re * im + im0
	%im_temp1 = mul double 2.0, %re
	%im_temp2 = mul double %im_temp1, %im
	%im_temp3 = add double %im_temp2, %im0
	store double %im_temp3, double* %im.addr

	br label %loop_over_t

max_reached:
  	ret double 0.0

escape_reached:
	%td = uitofp i32 %t to double
	; uncomment to debug when escape is reached
	; %print.dres = call i32 (i8*, ...)* @printf(i8* getelementptr ([5 x i8]* @"print_double", i32 0, i32 0), double %td)
	ret double %td
}


; main mandelbrot code
; Fills UP IMG table
define i32 @mandelbrot(double %xc, double %yc, i32 %max) {

       ; local variables
       %x.a = alloca double       
       %y.a = alloca double
       %i.a = alloca i32
       %j.a = alloca i32

       ; init
       %max.d = uitofp i32 %max to double ; convert to double for later calculations
       %w = load i32* @W
       %w.d = uitofp i32 %w to double
       %h = load i32* @H
       %h.d = uitofp i32 %h to double
       %zoom = load double* @ZOOM
       %zoom_div2 = fdiv double %zoom, 2.0
       %xinc = fdiv double %zoom, %w.d
       %xstart = sub double %xc, %zoom_div2
       %yinc = fdiv double %zoom, %h.d
       %ystart = sub double %yc, %zoom_div2

       ; loop over x, i=0; i<W
       store i32 0, i32* %i.a
       br label %loop_over_x

loop_over_x:
       store double %xc, double* %x.a
       %i = load i32* %i.a

       %i.d = uitofp i32 %i to double
       %xoffset = mul double %xinc, %i.d 
       %x = add double %xstart, %xoffset;

       ; loop over y, j=0; j<H
       store i32 0, i32* %j.a
       br label %loop_over_y

loop_over_y:
       %j = load i32* %j.a

       %j.d = uitofp i32 %j to double
       %yoffset = mul double %yinc, %j.d 
       %y = add double %ystart, %yoffset;

       %res = call double @mand(double %x, double %y, i32 %max)

       ; convert res to color
       %1 = fmul double %res, 255.
       %2 = fdiv double %1, %max.d
       %3 = fptoui double %2 to i32
       %4 = urem i32 %3, 256 ; % 256
       %color = trunc i32 %4 to i8

       ; %print.res = call i32 (i8*, ...)* @printf(i8* getelementptr ([14 x i8]* @"print_point_color", i32 0, i32 0), double %x, double %y, i32 %4)
       
       %pixel.a = getelementptr [2048 x [2048 x i8]]* @IMG, i32 0, i32 %i, i32 %j
       store i8 %color, i8* %pixel.a

       %j1 = add i32 1, %j
       store i32 %j1, i32* %j.a 
       %cond_y = icmp eq i32 %j1, %h
       br i1 %cond_y, label %done_y, label %loop_over_y ;

done_y:
       %i1 = add i32 1, %i
       store i32 %i1, i32* %i.a 
       %cond_x = icmp eq i32 %i1, %w
       br i1 %cond_x, label %done, label %loop_over_x ;

done:
       ret i32 0
}

define i32 @main() {
       ; init local variables from constants defined at the top
       %xc = load double* @XC
       %yc = load double* @YC
       %w = load i32* @W
       %h = load i32* @H
       %max = load i32* @MAXITER

       ; call mandelbrot code to fill up IMG pixels
       %res = call i32 @mandelbrot(double %xc, double %yc, i32 %max)

       ; save img as bitamp.bmp by calling an utility C function
       call void @write_bmp(i8* bitcast ([2048 x [2048 x i8]]* @IMG to i8*), i32 %w, i32 %h)
       
       ret i32 0
}