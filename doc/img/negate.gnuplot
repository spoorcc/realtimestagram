# Sigmoid plot
# ------------
# generate plot with:
# > gnuplot sigmoid.gnuplot

# Render settings
set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 750, 500 
set output 'bld/negate.png'

# Labels
set title "Negate"
set xlabel 'Input intensity'
set ylabel 'Output intensity'
set samples 200
set xtics 32
set ytics 32
set xrange [0:256]
set yrange [0:256]
set zeroaxis
set grid
set key right top

# color definitions
set style line 1  lc rgb '#0025ad' lt 1 lw 1.5

max_val=255.

f(x,c) = max_val - x

plot c=1 f(x,c) ls 1 title "f(x) = -x"
