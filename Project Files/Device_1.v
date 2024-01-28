`timescale 1 ns/100 ps
module Device_1(input Reset_Device1, 
			clk_Device1,
			load_message_Device1,
			RX_Device_1,
		input [63:0] Message_in_Device_1,
		output TX_Device_1
		 );


wire [7:0] w1,w2;
wire w3,w4,w5;

UART_Module Device_1_UART (
    .TX(TX_Device_1),
    .Byte_Out(w1),
    .RX(RX_Device_1),
    .clk(clk_Device1),
    .Byte_In(w2),
    .load(w3),
    .reset(Reset_Device1),
    .byte_has_been_sent(w4),
    .byte_has_been_received(w5)
);

 Chat_bot Device_1_Chat_Bot(
	.Byte_Out(w2),
	.Load_Byte(w3),
	.Byte_In(w1),
	.load_message(load_message_Device1),
	.byte_has_been_sent(w4),
	.byte_has_been_received(w5),
	.Message_In(Message_in_Device_1),
	.clk(clk_Device1),
	.reset(Reset_Device1)
		);

endmodule
