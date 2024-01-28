`timescale 1 ns/100 ps
module Chat_bot(
		Byte_Out,
		Load_Byte,
		Byte_In,
		load_message,
		byte_has_been_sent,
		byte_has_been_received,
		Message_In,
		clk,
		reset
		);



// character that will be sent to UART
output reg [7:0] Byte_Out; 

// Signal that will send to UART to load the byte
output reg Load_Byte;

// Message that will be sent out 


input [7:0] Byte_In;

// Message that will be 8 bytes
input [63:0] Message_In;

// Signal From UART to say the byte has been sent
// finished sending and time to send another byte
input byte_has_been_sent;
//
// Signal from UART to say the byte has been re
input byte_has_been_received;



// Singal to get out of idle and the message will be loaded
// will come from UART
input load_message;

input clk;
input reset;

// States for Sending a Byte
parameter Idle_Send = 2'b00;
parameter Load_Message = 2'b01;
parameter Tranmit_Message = 2'b10;
parameter Wait_for_previos_byte_to_finish = 2'b11;


reg [63:0] message_to_be_sent;
reg [1:0] State_Send;
reg [3:0] Byte_Counter;

//*****************************

// States for Receiving a Byte
parameter Idle_Receive = 2'b00;
parameter Recieve_Byte = 2'b01;
parameter Wait_for_next_byte_to_send = 2'b10;
parameter Print_Message_on_Terminal= 2'b11;



// registers for receiving a Byte
reg [63:0] message_received;
reg [1:0] State_Receieve;
reg [3:0] Byte_Counter_Receive;
reg [7:0] Character;
reg [3:0] counter_for_character;

// always block to send a message byte by byte to UART
always@(posedge clk)
begin
//
if(reset == 1)
begin
	message_to_be_sent <= 0;
	State_Send <= Idle_Send;
	Byte_Counter <=0;
	Character<=0;
	counter_for_character<=0;
	
end
//
case(State_Send)

	Idle_Send:
	begin
	Byte_Counter <=0;
	counter_for_character<=0;
	if(load_message == 1) 
		State_Send<= Load_Message;
	else
		State_Send<= Idle_Send;
	end
	Load_Message:
	begin
		message_to_be_sent <= Message_In;
		State_Send <= Tranmit_Message;
		
	end

	Tranmit_Message:
	begin

	if((Byte_Counter < 8) | (Byte_Counter == 8) )
	begin

		Load_Byte<=1;
		Byte_Out <= message_to_be_sent[63:56];
		message_to_be_sent <= message_to_be_sent << 8;
		Byte_Counter = Byte_Counter +1;
		State_Send <= Wait_for_previos_byte_to_finish;

	end
	
	else

	begin
		Load_Byte <=0;
		State_Send <= Idle_Send;
	end

	end
	Wait_for_previos_byte_to_finish:
	begin
	
	if(byte_has_been_sent ==1)
		State_Send <=Tranmit_Message;
	
	else
		State_Send <= Wait_for_previos_byte_to_finish;
	end


	default: State_Send <= Idle_Send;
	endcase


end 

// always block to receive a message from UART
always@(posedge clk)
begin

if (reset == 1)
begin
	message_received <=0;
	State_Receieve <=Idle_Receive;
	Byte_Counter_Receive<=0;
end


// always block to receive a message byte by byte from UART
case(State_Receieve)

	Idle_Receive:
	begin
	Byte_Counter_Receive<=0;
	message_received<=0;
	if(byte_has_been_received ==1)
	State_Receieve <= Recieve_Byte;
	else 
	State_Receieve <= Idle_Receive;

	end

	Recieve_Byte:
	begin
	
	if(Byte_Counter_Receive < 8)
	begin
		message_received <= {message_received[55:0], Byte_In};
		Byte_Counter_Receive <= Byte_Counter_Receive+1;
		State_Receieve <= Wait_for_next_byte_to_send;

	end

	else
		
		State_Receieve <= Print_Message_on_Terminal;
	end
	
	Wait_for_next_byte_to_send:
	begin
		if(byte_has_been_received == 1 )
			State_Receieve <= Recieve_Byte;
		else
			State_Receieve <= Wait_for_next_byte_to_send;
	

	end

	Print_Message_on_Terminal:
	begin
		if(counter_for_character < 8)
		begin
			Character <= message_received[63:56];
			message_received <= message_received << 8;
			
			case(Character)
				8'h61:  $write("a");
				8'h62:  $write("b");
				8'h63:  $write("c");
				8'h64:  $write("d");
				8'h65:  $write("e");
				8'h66:  $write("f");
				8'h67:  $write("g");
				8'h68:  $write("h");
				8'h69:  $write("i");
				8'h6A:  $write("j");
				8'h6B:  $write("k");
				8'h6C:  $write("l");
				8'h6D:  $write("m");
				8'h6E:  $write("n");
				8'h6F:  $write("o");
				8'h70:  $write("p");
				8'h71:  $write("q");
				8'h72:  $write("r");
				8'h73:  $write("s");
				8'h74:  $write("t");
				8'h75:  $write("u");
				8'h76:  $write("v");
				8'h77:  $write("w");
				8'h78:  $write("x");
				8'h79:  $write("y");
				8'h7A:  $write("z");
				8'h20:  $write(" ");
				default:  $write(" ");
			endcase
			counter_for_character <= counter_for_character +1;
			State_Receieve <= Print_Message_on_Terminal;
		end 

		else

			State_Receieve <= Idle_Receive;
		

	end
	
	default: State_Receieve <= Idle_Receive;
	endcase
end


endmodule
//