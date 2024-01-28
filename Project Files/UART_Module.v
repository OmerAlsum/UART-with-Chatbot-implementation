// Clk_cycles_per_bit = (Freqeuncy of CLK)/ (Frequency of UART)
// In our case, 50 MHz clk, 115200 baud rate
`timescale 1 ns/100 ps
module UART_Module
	#(parameter Clk_cycles_per_bit = 434)
		(TX,
		Byte_Out,
		byte_has_been_sent,
		byte_has_been_received,
		RX,
		clk,
		Byte_In,
		load,
		reset
		);


output reg TX;
output reg [7:0] Byte_Out;
output reg byte_has_been_sent;
output reg byte_has_been_received;
input RX;
input clk;
input reset;
input load;
input [7:0] Byte_In;
// Regiters and states for receiving a message 
// The buffer will have the parity bit too
// the parity bit will be in the LSB
reg [8:0] Buffer_In; 

reg [2:0] State_RX;
reg [8:0] Clock_Count_RX;
reg [3:0] Bit_Count_Rev;
wire odd_parity_check_RX;
//
// states for Receiving block
parameter Idle_RX = 3'b000;
parameter Start_of_Packet = 3'b001;
parameter Receieve_Data_Serially = 3'b010;
parameter Parity_Checker = 3'b011;
parameter Send_Data_Parallal = 3'b100;
parameter Stop_Bit=3'b101;

//********************************************
// Registers and States for transmitting a message
// 
reg [10:0] packet;
wire odd_parity_check_TX;
reg [2:0] State_TX;
reg [8:0] Clock_Count_TX;
reg [3:0] Bit_Counter_TX;

// States for sending a message
parameter Idle_TX = 3'b000;
parameter Create_Packet = 3'b001;
parameter Transmit_Data = 3'b010;

assign odd_parity_check_TX = Byte_In[0] ^ Byte_In[1] ^ Byte_In[2] ^ Byte_In[3]^ 
				Byte_In[4] ^ Byte_In[5] ^ Byte_In[6] ^ Byte_In[7];

assign odd_parity_check_RX = Buffer_In[0] ^ Buffer_In[1] ^ Buffer_In[2] ^ Buffer_In[3]^ 
				Buffer_In[4] ^ Buffer_In[5] ^ Buffer_In[6] ^ Buffer_In[7] ^ Buffer_In[8];
//
// always block for receving a byte
always@(negedge clk, posedge reset)

begin

	if(reset == 1) // if the reset is high, then reset all of registers and go to Idle
	begin
		Buffer_In <= 0;
		State_RX <= Idle_RX;
		Clock_Count_RX <= 0;
		Bit_Count_Rev <= 0; 
		byte_has_been_received<= 0;
		
	end

	
	case(State_RX)

	Idle_RX:
	begin
		
		if(RX == 1'b0) // If the Recveing bit is 1, then the Start bit detected
		begin
			Buffer_In <= 0;
			State_RX<= Start_of_Packet;
			Clock_Count_RX <=0;
			Bit_Count_Rev<=0;
			//byte_has_been_received<=0; // send the signal low 
		end
		else
			State_RX <= Idle_RX;
		

	end

	Start_of_Packet:
	begin
		if(Clock_Count_RX == (Clk_cycles_per_bit -1)/2) // find the middle of the start bit
		begin
			Clock_Count_RX <= 0;
			State_RX <= Receieve_Data_Serially;
		end

		else 
		begin
			Clock_Count_RX <= Clock_Count_RX + 1;
			State_RX <= Start_of_Packet;

		end
	end 

	Receieve_Data_Serially:

	begin
	
		if(Clock_Count_RX == Clk_cycles_per_bit-1)
  
		begin	
			if((Bit_Count_Rev < 8) | (Bit_Count_Rev==8) ) // checks to see if we have received all 8 bits
			begin
				Buffer_In <= {Buffer_In[7:0], RX}; // shifts the incoming RX bit to the left
				Bit_Count_Rev <= Bit_Count_Rev +1;
				Clock_Count_RX <= 0;
				State_RX <= Receieve_Data_Serially;
			end
			else 
			begin
				Clock_Count_RX <= 0;
				State_RX <= Parity_Checker;
			end
		end
		else 
		begin
			Clock_Count_RX <= Clock_Count_RX + 1;
			State_RX <= Receieve_Data_Serially;

		end

	end



	Parity_Checker:

	begin
		

			if(odd_parity_check_RX == 1) // if result is 1, then no error detection
			begin
				Clock_Count_RX <= 0;
				State_RX <= Send_Data_Parallal;
			end
			else // if result is 0, then there was an error, data is not sent out and the we go back into idle
			begin
				Clock_Count_RX <= 0;
				State_RX <= Stop_Bit;
			end
	

	end

	Send_Data_Parallal:
	begin
		byte_has_been_received<=1;
		Byte_Out <= Buffer_In[8:1]; // data will be in the upper 8 bits of the buffer
		State_RX <= Stop_Bit;
		
	end

	Stop_Bit:
	begin
		byte_has_been_received<=0;
		if(Clock_Count_RX == Clk_cycles_per_bit-1)
		begin
			// End of Packet should always be a 1
				byte_has_been_received<=0;
				State_RX <= Idle_RX;
			
		end
		else 
		begin
			Clock_Count_RX <= Clock_Count_RX + 1;
			State_RX <= Stop_Bit;


		end
		
	end 

	

	default:
		State_RX <= Idle_RX;
	endcase 
end

// always block for sending a message
// might be posedge, will see during testing 
always @(negedge clk or posedge reset)
begin

	if(reset ==1)
	begin
		Clock_Count_TX <= 0;
		packet <= 0;
		Bit_Counter_TX<=0;
		State_TX <= Idle_TX;
		Bit_Counter_TX<=0;
		TX<=1;
		byte_has_been_sent<=0;
		//
	end
	
	case(State_TX)

	Idle_TX:

	begin
		  // setting the signal to low to not confuse Chat Bot
		if(load ==1)
		begin
			byte_has_been_sent<=0; // 
			Clock_Count_TX <= 0;
			State_TX <= Create_Packet;
			Bit_Counter_TX<=0;
		end
		else 
		begin
			TX<= 1;
			Clock_Count_TX <= 0;
			State_TX <= Idle_TX;
		end
	end

	Create_Packet: // create the packet
	begin

		
		

		if(odd_parity_check_TX ==1) 
		begin
			packet <= {1'b0,Byte_In,1'b0,1'b1};
			State_TX <=Transmit_Data;
		end
		else
		begin
			packet <= {1'b0,Byte_In,1'b1,1'b1};
			State_TX <=Transmit_Data;
			
		end
	end

	Transmit_Data:
	begin

		if(Clock_Count_TX == Clk_cycles_per_bit)
		begin
			if((Bit_Counter_TX < 10) | (Bit_Counter_TX==10) )
			begin
				TX <= packet[10];
				packet <= packet << 1; 
				Bit_Counter_TX <= Bit_Counter_TX +1;
				Clock_Count_TX <= 0;
				State_TX <= Transmit_Data;
			end 
			else // full byte has been sent
			begin 
				TX <= 1;
				byte_has_been_sent <=1;
				Clock_Count_TX <= 0;
				State_TX <= Idle_TX;
			end
		end
		else 
		begin
			Clock_Count_TX <= Clock_Count_TX + 1;
			State_TX <=Transmit_Data ;


		end

	end
	default:
		State_TX <= Idle_TX;
	endcase
end 



endmodule 
