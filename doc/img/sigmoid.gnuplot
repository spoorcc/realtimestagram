# Sigmoid plot
# ------------
# generate plot with:
# > gnuplot sigmoid.gnuplot

# Render settings
set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 750, 500 
set output 'bld/sigmoid.png'

# Labels
set title "Sigmoid"
set xlabel 'Input intensity'
set ylabel 'Output intensity'
set samples 200
set xtics 32
set ytics 32
set xrange [0:256]
set yrange [0:256]
set zeroaxis
set grid
set nokey # No legend

max_val=255.

f(x,c) = max_val / (1.+exp( -(c/max_val)*(x-max_val/2.)))

plot for [c=0.1:25:3] f(x,c), c**2
