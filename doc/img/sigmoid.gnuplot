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
set key left top

# color definitions
set style line 1  lc rgb '#0025ad' lt 1 lw 1.5
set style line 3  lc rgb '#0042ad' lt 1 lw 1.5
set style line 5  lc rgb '#007cad' lt 1 lw 1.5
set style line 7  lc rgb '#00ada4' lt 1 lw 1.5
set style line 9  lc rgb '#00ad6b' lt 1 lw 1.5
set style line 11 lc rgb '#00ad31' lt 1 lw 1.5

max_val=255.

f(x,c) = max_val / (1.+exp( -(c/max_val)*(x-max_val/2.)))

plot for [c=1:11:2] f(x,c) ls c title sprintf("C = %1.2f",c)
