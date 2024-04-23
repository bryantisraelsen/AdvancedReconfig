onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/RX
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/rx_conv_state
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/neg_sign_flag
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/rx_fifo_in
add wave -noupdate /dlx_proc_tb/dlx_er/rx_fifo_write
add wave -noupdate /dlx_proc_tb/dlx_er/rx_fifo_read
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/rx_read_value
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/rx_fifo_out
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/mult_in
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/mult_out
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/receive_fifo_wr
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/receive_fifo_out
add wave -noupdate /dlx_proc_tb/dlx_er/receive_fifo_empty
add wave -noupdate /dlx_proc_tb/dlx_er/receive_fifo_rd
add wave -noupdate /dlx_proc_tb/dlx_er/char_stall
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/wait_char_stall
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/take_branch
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/op_code
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/prev_op_code0
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/prev_op_code1
add wave -noupdate -expand -group Execute /dlx_proc_tb/dlx_er/execute_order_66/unsigned_valid
add wave -noupdate -expand -group Execute /dlx_proc_tb/dlx_er/char_wr
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/ALU_out
add wave -noupdate -expand -group Execute /dlx_proc_tb/dlx_er/execute_order_66/sixty_four_valid
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/sixty_four_upper_bits
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/storred_upper_y
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/ALU_in_0
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/ALU_in_1
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/received_data_valid
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/received_data_read
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/instruct
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/HEX0
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/HEX1
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/HEX2
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/HEX3
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/HEX4
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/HEX5
add wave -noupdate -group StopWatch /dlx_proc_tb/dlx_er/hex_0
add wave -noupdate -group StopWatch /dlx_proc_tb/dlx_er/hex_1
add wave -noupdate -group StopWatch /dlx_proc_tb/dlx_er/hex_2
add wave -noupdate -group StopWatch /dlx_proc_tb/dlx_er/hex_3
add wave -noupdate -group StopWatch /dlx_proc_tb/dlx_er/hex_4
add wave -noupdate -group StopWatch /dlx_proc_tb/dlx_er/hex_5
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/stopWatch_start
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/stopWatch_stop
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/stopWatch_reset
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/stopWatch_go
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/cnt_incr
add wave -noupdate -group StopWatch -radix hexadecimal /dlx_proc_tb/dlx_er/incr
add wave -noupdate -group Tx -radix hexadecimal /dlx_proc_tb/dlx_er/tx_rd
add wave -noupdate -group Tx -radix hexadecimal /dlx_proc_tb/dlx_er/tx_data_valid
add wave -noupdate -group Tx -radix hexadecimal /dlx_proc_tb/dlx_er/tx_fifo_full
add wave -noupdate -group Tx -radix hexadecimal /dlx_proc_tb/dlx_er/tx_fifo_out
add wave -noupdate -group Tx -radix hexadecimal /dlx_proc_tb/dlx_er/tx_fifo_empty
add wave -noupdate -group Tx -radix hexadecimal /dlx_proc_tb/dlx_er/tx_fifo_write
add wave -noupdate -group Tx -radix hexadecimal /dlx_proc_tb/dlx_er/tx_fifo_in
add wave -noupdate -group Divider /dlx_proc_tb/dlx_er/dec_state
add wave -noupdate -group Divider -radix hexadecimal /dlx_proc_tb/dlx_er/storred_num
add wave -noupdate -group Divider -radix hexadecimal /dlx_proc_tb/dlx_er/s_div_num_valid
add wave -noupdate -group Divider -radix hexadecimal /dlx_proc_tb/dlx_er/u_div_num_valid
add wave -noupdate -group Divider -radix hexadecimal /dlx_proc_tb/dlx_er/div_wait_cnt
add wave -noupdate -group Divider -radix hexadecimal /dlx_proc_tb/dlx_er/sig_conv
add wave -noupdate -group Divider -radix hexadecimal /dlx_proc_tb/dlx_er/unsig_div_num
add wave -noupdate -group Divider -radix hexadecimal /dlx_proc_tb/dlx_er/unsig_div_remain
add wave -noupdate -group Divider -radix hexadecimal /dlx_proc_tb/dlx_er/unsig_div_quot
add wave -noupdate -group {Print Val FIFO} -radix hexadecimal /dlx_proc_tb/dlx_er/print_val_fifo_empty
add wave -noupdate -group {Print Val FIFO} -radix hexadecimal /dlx_proc_tb/dlx_er/print_val_fifo_valid
add wave -noupdate -group {Print Val FIFO} -radix hexadecimal /dlx_proc_tb/dlx_er/print_val_fifo_rd
add wave -noupdate -group {Print Val FIFO} -radix hexadecimal /dlx_proc_tb/dlx_er/print_val_fifo_out
add wave -noupdate -group Stack /dlx_proc_tb/dlx_er/stack_wr
add wave -noupdate -group Stack -radix hexadecimal /dlx_proc_tb/dlx_er/stack_in
add wave -noupdate -group Stack /dlx_proc_tb/dlx_er/stack_rd
add wave -noupdate -group Stack -radix hexadecimal /dlx_proc_tb/dlx_er/stack_out
add wave -noupdate -group Stack /dlx_proc_tb/dlx_er/stack_empty
add wave -noupdate -expand -group {Write back} -radix hexadecimal /dlx_proc_tb/dlx_er/writer/reg_wr_address
add wave -noupdate -expand -group {Write back} -radix hexadecimal /dlx_proc_tb/dlx_er/writer/reg_wr_data
add wave -noupdate -expand -group {Write back} -radix hexadecimal /dlx_proc_tb/dlx_er/writer/reg_wr_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {799718919 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 379
configure wave -valuecolwidth 149
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {396073 ps}
