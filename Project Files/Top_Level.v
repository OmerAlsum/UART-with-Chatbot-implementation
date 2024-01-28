`timescale 1 ns/100 ps
module Top_Level (
    input Reset_Device1, Reset_Device2,
    input clk_Device1,clk_Device2,
    input load_message_Device1, load_message_Device2,
    input [63:0] message_in_Device1, message_in_Device2
);

wire w1,w2,w3;


Device_1 D1(
	.Reset_Device1(Reset_Device1), 
	.clk_Device1(clk_Device1),
	.load_message_Device1(load_message_Device1),
	.RX_Device_1(w2),
	.Message_in_Device_1(message_in_Device1),
	.TX_Device_1(w1)
		 );

Device_2 D2(
	.Reset_Device2(Reset_Device2), 
	.clk_Device2(clk_Device2),
	.load_message_Device2(load_message_Device2),
	.RX_Device_2(w1),
	.Message_in_Device_2(message_in_Device2),
	.TX_Device_2(w2)
		 );


endmodule 