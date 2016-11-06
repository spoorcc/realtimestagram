# Hue plot
# ------------
# generate plot with:
# > gnuplot hue.gnuplot

# Render settings
set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 750, 500 
set output 'bld/hue_calc.png'

max_x=360
max_y=255

y_margin=60

# Labels
set title "Hue"
set xlabel 'Hue'
set ylabel 'Value'
set samples 1500
set xtics 30
set ytics 32
set xrange [0:max_x]
set yrange [-y_margin:max_y+y_margin]
set zeroaxis
set grid
set key left top

# Lines
red(x)   = x<60 ? max_y : x<120 ? max_y-(max_y/60.0)*(x-60): x < 240 ? 0 : x < 300 ? (max_y/60.0)*(x-240) : max_y
green(x) = x<60 ? (max_y/60.0)*x: x<180 ? max_y : x < 240 ?  max_y-(max_y/60.0)*(x-180) : 0
blue(x)  = x<120 ? 0 : x<180 ? (max_y/60.0)*(x-120): x<300 ? max_y : max_y-(max_y/60.0)*(x-300)

hue(x)  = floor(max_y/360.0 * x)

plot red(x) title "red" lc rgb '#ff0000' lt 1, \
     green(x) title "green" lc rgb '#00ff00' lt 1, \
     blue(x) title "blue" lc rgb '#0000ff' lt 1, \
     hue(x) title "Calculated Hue" lc rgb '#000000' lt 1, \
