# Vignette curve plot
# ------------
# generate plot with:
# > gnuplot vignette_curve.gnuplot

# Render settings
set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 750, 500 
set output 'bld/vignette_curve.png'

max_val=255.
w=640

# Labels
set title "Vignette curve"
set xlabel 'Pixel x position'
set ylabel 'Amplification factor'
set samples 200
set xtics 64
set ytics .25
set xrange [0:w]
set yrange [0:1.1]
set zeroaxis
set grid
set key left top

# color definitions
set style line 1 lc rgb '#0025ad' lt 1 lw 1.5
set style line 2 lc rgb '#0042ad' lt 1 lw 1.5
set style line 3 lc rgb '#007cad' lt 1 lw 1.5
set style line 4 lc rgb '#00ada4' lt 1 lw 1.5
set style line 5 lc rgb '#00ad6b' lt 1 lw 1.5
set style line 6 lc rgb '#00ad31' lt 1 lw 1.5

f(x,c) = (sin(pi/w *x)**c)

plot for [c=1:6] f(x,c) ls c title sprintf("C = %1.2f",c)
