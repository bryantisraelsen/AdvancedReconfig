onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/RX
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/rx_conv_state
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/chars_left
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/neg_sign_flag
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/rx_fifo_in
add wave -noupdate /dlx_proc_tb/dlx_er/rx_fifo_write
add wave -noupdate /dlx_proc_tb/dlx_er/rx_fifo_read
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/rx_read_value
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/rx_fifo_out
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/rx_conv_start
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/mult_in
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/mult_out
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/receive_fifo_wr
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/wrusedw
add wave -noupdate -radix hexadecimal /dlx_proc_tb/dlx_er/receive_fifo_out
add wave -noupdate /dlx_proc_tb/dlx_er/receive_fifo_empty
add wave -noupdate /dlx_proc_tb/dlx_er/receive_fifo_rd
add wave -noupdate /dlx_proc_tb/dlx_er/char_stall
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/wait_char_stall
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/take_branch
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/op_code
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/prev_op_code0
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/prev_op_code1
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/ALU_out
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/received_data_valid
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/received_data_read
add wave -noupdate -expand -group Execute -radix hexadecimal /dlx_proc_tb/dlx_er/execute_order_66/instruct
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {557272 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 333
configure wave -valuecolwidth 100
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
WaveRestoreZoom {504338 ps} {944522 ps}
