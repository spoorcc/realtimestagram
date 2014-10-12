# Sigmoid plot
# ------------
# generate plot with:
# > gnuplot sigmoid.gnuplot

# Render settings
set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 750, 500 
set output 'bld/gamma.png'

# Labels
set title "Gamma"
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
set style line 2 lc rgb '#0025ad' lt 1 lw 1.5
set style line 3 lc rgb '#0042ad' lt 1 lw 1.5
set style line 4 lc rgb '#007cad' lt 1 lw 1.5
set style line 5 lc rgb '#00ada4' lt 1 lw 1.5
set style line 6 lc rgb '#00ad6b' lt 1 lw 1.5
set style line 7 lc rgb '#00ad31' lt 1 lw 1.5

max_val=255.

f(x,g) = (max_val)*(x/max_val)**g

plot for [g=2:7:1] f(x,(g/3.)**3) ls g title sprintf("g = %2.2f",(g/3.)**3)
