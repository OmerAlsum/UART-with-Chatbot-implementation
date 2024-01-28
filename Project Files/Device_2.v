`timescale 1 ns/100 ps
module Device_2(input Reset_Device2, 
			clk_Device2,
			load_message_Device2,
			RX_Device_2,
		input [63:0] Message_in_Device_2,
		output TX_Device_2
		 );


wire [7:0] w1,w2;
wire w3,w4,w5;

UART_Module Device_2_UART (
    .TX(TX_Device_2),
    .Byte_Out(w1),
    .RX(RX_Device_2),
    .clk(clk_Device2),
    .Byte_In(w2),
    .load(w3),
    .reset(Reset_Device2),
    .byte_has_been_sent(w4),
    .byte_has_been_received(w5)
);

 Chat_bot Device_2_Chat_Bot(
	.Byte_Out(w2),
	.Load_Byte(w3),
	.Byte_In(w1),
	.load_message(load_message_Device2),
	.byte_has_been_sent(w4),
	.byte_has_been_received(w5),
	.Message_In(Message_in_Device_2),
	.clk(clk_Device2),
	.reset(Reset_Device2)
);

endmodule
