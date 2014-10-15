# Vignette plot
# ------------
# generate plot with:
# > gnuplot vignette.gnuplot

max_val=256.
w=640.
h=512.

set xtics 128
set ytics 128

# Render settings
set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size w,h 
set output 'bld/vignette.png'

set title "Vignette"
set nokey

set xrange [0:(w-1)]
set yrange [0:(h-1)]
set zrange [0:max_val-1]
set samples w,h
set pm3d map interpolate 0,0
set palette gray

splot sin(pi/w * x) + sin(pi/h * y)
