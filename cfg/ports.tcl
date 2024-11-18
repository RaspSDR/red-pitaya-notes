
### ADC

create_bd_port -dir I -from 15 -to 0 adc_dat_a_i

create_bd_port -dir I adc_clk_p_i
create_bd_port -dir I adc_clk_n_i

create_bd_port -dir I adc_ofl_i

### Misc

create_bd_port -dir I pps_i

### Antenna Switch
create_bd_port -dir O -from 7 -to 0 antenna_o

### LED

create_bd_port -dir O led_o
