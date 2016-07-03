`timescale 1ps/1ps

module main();

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(1,main);
        $dumpvars(1,i0);

	reg_file[0][19:16] = 0;
	reg_file[1][19:16] = 0;
	reg_file[2][19:16] = 0;
	reg_file[3][19:16] = 0;
	reg_file[4][19:16] = 0;
	reg_file[5][19:16] = 0;
	reg_file[6][19:16] = 0;
	reg_file[7][19:16] = 0;
	reg_file[8][19:16] = 0;
	reg_file[9][19:16] = 0;
	reg_file[10][19:16] = 0;
	reg_file[11][19:16] = 0;
	reg_file[12][19:16] = 0;
	reg_file[13][19:16] = 0;
	reg_file[14][19:16] = 0;
	reg_file[15][19:16] = 0;

    end

    // clock
    wire clk;
    clock c0(clk);

    wire halt = ~(reservation_valid(ld_rs_0)||reservation_valid(ld_rs_1)||reservation_valid(fx_rs_0)||reservation_valid(fx_rs_1))&&is_halt(branch_entry)&&~final_halt;
    reg final_halt = 0;
    wire [2:0]insts_executed = cdb_1[16]+cdb_2[16]+cdb_3[16]+cdb_4[16]+(cdb_5[17]||cdb_5[16])+cdb_6[16];
    counter ctr(final_halt,clk,insts_executed,cycle);

    // regs
    reg [19:0]reg_file[0:15];

    // PC
    reg [15:0]pc = 16'h0000;
    wire [15:0]pc1 = pc + 1;

    //Instruction buffer metadata
    reg[9:0]IBqhead = 0;
    reg[9:0]IBqtail = 0;
    reg[9:0]IBqsize = 0;
    reg[31:0]IBq[0:1023];
    wire IBqfull = IBqsize > 256;

    //reservation station data
    reg[67:0]ld_rs_0   = 0;
    reg[67:0]ld_rs_1   = 0;
    reg[67:0]fx_rs_0   = 0;
    reg[67:0]fx_rs_1   = 0;
    reg[67:0]branch_rs = 0;
    reg[67:0]print_rs  = 0;

    //only to be used for the second instruction being dispatched
    wire ld_rs_0_open = ~reservation_valid(ld_rs_0)&&~(dispatch_destination_0==1);
    wire ld_rs_1_open = ~reservation_valid(ld_rs_1)&&~(dispatch_destination_0==2);
    wire fx_rs_0_open = ~reservation_valid(fx_rs_0)&&~(dispatch_destination_0==3);
    wire fx_rs_1_open = ~reservation_valid(fx_rs_1)&&~(dispatch_destination_0==4);
    wire branch_rs_open = ~reservation_valid(branch_rs)&&~(dispatch_destination_0==5);
    wire print_rs_open = ~reservation_valid(print_rs)&&~(dispatch_destination_0==6);

    // fetch 
    wire [15:0]fetchOut;
    wire fetchReady;
    wire [15:0]fetchOutpc;
    wire [15:0]fetchOut1;
    wire fetchReady1;
    wire [15:0]fetchOutpc1;

    // load 
    wire [15:0]loadOut0;
    wire loadReady0;
    wire loadEnaible0;
    wire [15:0]loadAddr0;
    wire [15:0]loadOut1;
    wire loadReady1;
    wire loadEnable1;
    wire [15:0]loadAddr1;
    reg ldu_0_is_loading=0;
    reg ldu_1_is_loading=0;
    //CDB
    wire [16:0]cdb_1 = ldu_0_data_0;
    wire [16:0]cdb_2 = ldu_1_data_0;
    wire [16:0]cdb_3 = fxu_0_data;
    wire [16:0]cdb_4 = fxu_1_data;
    wire [17:0]cdb_5 = branch_data;
    wire [16:0]cdb_6 = print_data;
    wire [3:0]cdb_1_dest = get_dest(ldu_0_entry);
    wire [3:0]cdb_2_dest = get_dest(ldu_0_entry);
    wire [3:0]cdb_3_dest = get_dest(fxu_0_entry);
    wire [3:0]cdb_4_dest = get_dest(fxu_1_entry);
    wire [3:0]cdb_5_dest = 0;
    //
    //Not sure about this
    //
    wire [3:0]cdb_6_dest = 0;
    wire [15:0]cdb_1_pc = ldu_0_entry[15:0];
    wire [15:0]cdb_2_pc = ldu_1_entry[15:0];
    wire [15:0]cdb_3_pc = fxu_0_entry[15:0];
    wire [15:0]cdb_4_pc = fxu_1_entry[15:0];
    wire [15:0]cdb_5_pc = branch_entry[15:0];
    wire [15:0]cdb_6_pc = print_entry[15:0];


    wire [15:0]next_pc = (IBqsize < 1022) ? pc + 2 : 
	      	         (IBqsize < 1023) ? pc + 1 : pc;	

    wire load_enabled_0_cpy = ldu_0_load_enabled;
    wire load_enabled_1_cpy = ldu_1_load_enabled;
    wire[15:0] load_from_0_cpy = ldu_0_load_from;
    wire[15:0] load_from_1_cpy = ldu_1_load_from;
    //Decide where the two LDUs are loading from
    mem i0(clk,
       /* fetch port */
       ~(IBqfull||cdb_5[16]),
       pc,
       fetchReady,
       fetchOut,
       fetchOutpc,

        (IBqsize < 1022&&~cdb_5[16]),
        pc1,
        fetchReady1,
        fetchOut1,
        fetchOutpc1,

        /* load port */
        //ldu_0_load_enabled,
        load_enabled_0_cpy,
        load_from_0_cpy,
        loadReady0,
        loadOut0,

        /* load port */
        load_enabled_1_cpy,
        load_from_1_cpy,
        loadReady1,
        loadOut1

);
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    |	     Start dispatching insts		    | 
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
  
    //Decide which instructions we should be dispatching
    wire[31:0]dispatching_inst_0 = (IBqsize == 0 && fetchReady) ? (fetchOut << 16 | fetchOutpc) :
                                   (IBqsize != 0) ? IBq[IBqhead] : (16'hf000 << 16);

    wire [2:0]dispatch_destination_0 = (!reservation_valid(branch_rs)) ?
               ((is_ld(dispatching_inst_0)||is_ldr(dispatching_inst_0))&&(~reservation_valid(ld_rs_0)||
		~(ldu_0_next_is_src_0|ldu_0_next_is_src_1)&&~ldu_0_is_loading) ? 1 :  
                (is_ld(dispatching_inst_0)||is_ldr(dispatching_inst_0))&&(~reservation_valid(ld_rs_1)||
		~(ldu_1_next_is_src_0|ldu_1_next_is_src_1)&&!ldu_1_is_loading) ? 2 :
                 is_fx(dispatching_inst_0)&&(~reservation_valid(fx_rs_0)||~(fxu_0_next_is_src_0|fxu_0_next_is_src_1)) ? 3 :                               
                 is_fx(dispatching_inst_0)&&(~reservation_valid(fx_rs_1)||~(fxu_1_next_is_src_0|fxu_1_next_is_src_1)) ? 4 :                               
                 is_jmp(dispatching_inst_0)||is_jeq(dispatching_inst_0)||is_halt(dispatching_inst_0) ? 5 : 
		 is_print(dispatching_inst_0)&&(~reservation_valid(print_rs)||~(print_next_is_src_0|print_next_is_src_1)) ? 6 : 0) : 0; 



    //Decide which instructions we should be dispatching
    wire[31:0]dispatching_inst_1 =  (dispatch_destination_0 > 0) ?
                                    ((IBqsize == 0 && fetchReady1) ? (fetchOut1 << 16 | fetchOutpc1) :
                                    (IBqsize == 1 && fetchReady) ? (fetchOut << 16 | fetchOutpc) :
                                    (IBqsize > 1) ? IBq[IBqhead+1] : (16'h7000 << 16)) : (16'hf000 << 16);


    //After we have found the correct instruction, decide where it needs to be dispatched 
    wire [2:0]dispatch_destination_1 = (branch_rs_open) ?                                                                                   
           ((is_ld(dispatching_inst_1)||is_ldr(dispatching_inst_1))&&~(dispatch_destination_0==1)
   	   &&(~reservation_valid(ld_rs_0)||~(ldu_0_next_is_src_0|ldu_0_next_is_src_1)&&~ldu_0_is_loading) ? 1 :  
           (is_ld(dispatching_inst_1)||is_ldr(dispatching_inst_1))&&~(dispatch_destination_0==2)
     	   &&(~reservation_valid(ld_rs_1)||~(ldu_1_next_is_src_0|ldu_1_next_is_src_1)&&~ldu_1_is_loading) ? 2 :
           is_fx(dispatching_inst_1)&&~(dispatch_destination_0==3)&&(~reservation_valid(fx_rs_0)||~(fxu_0_next_is_src_0|fxu_0_next_is_src_1)) ? 3 : 
           is_fx(dispatching_inst_1)&&~(dispatch_destination_0==4)&&(~reservation_valid(fx_rs_1)||~(fxu_1_next_is_src_0|fxu_1_next_is_src_1)) ? 4 :
	   is_print(dispatching_inst_1)&&~(dispatch_destination_0==6)&&(~reservation_valid(print_rs)||~(print_next_is_src_0|print_next_is_src_1)) ? 6 : 0) : 0; 
  
    //After we decide where each instruction is going, decide if there is a depencdency
    wire rs_0_dest = get_dest(dispatching_inst_0);
    wire rs_0_is_src_0 = ~(rs_0_src_0==0||rs_0_src_0_is_on_cdb); 
    wire rs_0_is_src_1 = ~(rs_0_src_1==0||rs_0_src_1_is_on_cdb); 
    wire rs_0_src_0_is_on_cdb = ((rs_0_src_0 == 1 && cdb_1[16] && ~(cdb_1_pc==dispatching_inst_0[15:0]||cdb_1_pc==dispatching_inst_1[15:0])) ||
				(rs_0_src_0 == 2 && cdb_2[16] && ~(cdb_2_pc==dispatching_inst_0[15:0]||cdb_2_pc==dispatching_inst_1[15:0])) ||
				(rs_0_src_0 == 3 && cdb_3[16] && ~(cdb_3_pc==dispatching_inst_0[15:0]||cdb_3_pc==dispatching_inst_1[15:0])) ||
				(rs_0_src_0 == 4 && cdb_4[16] && ~(cdb_4_pc==dispatching_inst_0[15:0]||cdb_4_pc==dispatching_inst_1[15:0])) ||
				(rs_0_src_0 == 5 && cdb_5[16] && ~(cdb_5_pc==dispatching_inst_0[15:0]||cdb_5_pc==dispatching_inst_1[15:0])) ||
				(rs_0_src_0 == 6 && cdb_6[16] && ~(cdb_6_pc==dispatching_inst_0[15:0]||cdb_6_pc==dispatching_inst_1[15:0])));
    wire rs_0_src_1_is_on_cdb = ((rs_0_src_1 == 1 && cdb_1[16] && ~(cdb_1_pc==dispatching_inst_0[15:0]||cdb_1_pc==dispatching_inst_1[15:0])) ||
				(rs_0_src_1 == 2 && cdb_2[16] && ~(cdb_2_pc==dispatching_inst_0[15:0]||cdb_2_pc==dispatching_inst_1[15:0])) ||
				(rs_0_src_1 == 3 && cdb_3[16] && ~(cdb_3_pc==dispatching_inst_0[15:0]||cdb_3_pc==dispatching_inst_1[15:0])) ||
				(rs_0_src_1 == 4 && cdb_4[16] && ~(cdb_4_pc==dispatching_inst_0[15:0]||cdb_4_pc==dispatching_inst_1[15:0])) ||
				(rs_0_src_1 == 5 && cdb_5[16] && ~(cdb_5_pc==dispatching_inst_0[15:0]||cdb_5_pc==dispatching_inst_1[15:0])) ||
				(rs_0_src_1 == 6 && cdb_6[16] && ~(cdb_6_pc==dispatching_inst_0[15:0]||cdb_6_pc==dispatching_inst_1[15:0])));
    wire [15:0]rs_0_src_0 = register_who(reg_file[dispatching_inst_0[27:24]]);
    wire [15:0]rs_0_src_1 = register_who(reg_file[dispatching_inst_0[23:20]]);
    wire [15:0]rs_0_src_or_data_0 = (rs_0_is_src_0) ? rs_0_src_0 : rs_0_data_0;
    wire [15:0]rs_0_src_or_data_1 = (rs_0_is_src_1) ? rs_0_src_1 : rs_0_data_1;
    wire [3:0]rs_0_reg_0 = dispatching_inst_0[27:24];
    wire [3:0]rs_0_reg_1 = dispatching_inst_0[23:20];
    wire rs_entry_0_ready = (is_mov(dispatching_inst_0) || is_ld(dispatching_inst_0)) ? 1 :
                            (has_two_src(dispatching_inst_0)) ? ~(rs_0_is_src_0 || rs_0_is_src_1) : 
                            ~(reservation_valid(ld_rs_0) || reservation_valid(ld_rs_1) || reservation_valid(fx_rs_0) || reservation_valid(fx_rs_1) || reservation_valid(print_rs));
    wire[15:0]rs_0_data_0 = (rs_0_src_0==1&&rs_0_src_0_is_on_cdb) ? cdb_1[15:0] :
			    (rs_0_src_0==2&&rs_0_src_0_is_on_cdb) ? cdb_2[15:0] :
			    (rs_0_src_0==3&&rs_0_src_0_is_on_cdb) ? cdb_3[15:0] :
			    (rs_0_src_0==4&&rs_0_src_0_is_on_cdb) ? cdb_4[15:0] :
			    (rs_0_src_0==5&&rs_0_src_0_is_on_cdb) ? cdb_5[15:0] : 
			    (rs_0_src_0==6&&rs_0_src_0_is_on_cdb) ? cdb_6[15:0] : reg_file[dispatching_inst_0[27:24]][15:0];
    wire[15:0]rs_0_data_1 = (rs_0_src_1==1&&rs_0_src_1_is_on_cdb) ? cdb_1[15:0] :
			    (rs_0_src_1==2&&rs_0_src_1_is_on_cdb) ? cdb_2[15:0] :
			    (rs_0_src_1==3&&rs_0_src_1_is_on_cdb) ? cdb_3[15:0] :
			    (rs_0_src_1==4&&rs_0_src_1_is_on_cdb) ? cdb_4[15:0] :
			    (rs_0_src_1==5&&rs_0_src_1_is_on_cdb) ? cdb_5[15:0] : 
			    (rs_0_src_1==6&&rs_0_src_1_is_on_cdb) ? cdb_6[15:0] : reg_file[dispatching_inst_0[23:20]][15:0];

                                                                                                                                                
    wire [67:0]rs_entry_0 = (has_two_src(dispatching_inst_0)) ? ((1<<67) |
                                                                (rs_entry_0_ready<<66) |
                                                                (rs_0_is_src_0<<65) |
                                                                (rs_0_is_src_1<<64) |
                                                                (rs_0_src_or_data_0<<48) |
                                                                (rs_0_src_or_data_1<<32) |
                                                                dispatching_inst_0) : ((1<<67) | (rs_entry_0_ready<<66) | dispatching_inst_0);
                                                                                                                                                    
    wire rs_1_dest = get_dest(dispatching_inst_1);
    wire rs_1_is_src_0 = ~(rs_1_src_0==0||rs_1_src_0_is_on_cdb); 
    wire rs_1_is_src_1 = ~(rs_1_src_1==0||rs_1_src_1_is_on_cdb);
    wire rs_1_src_0_is_on_cdb = ((rs_1_src_0 == 1 && cdb_1[16] && ~(cdb_1_pc==dispatching_inst_1[15:0])) ||
				(rs_1_src_0 == 2 && cdb_2[16] && ~(cdb_2_pc==dispatching_inst_1[15:0])) ||
				(rs_1_src_0 == 3 && cdb_3[16] && ~(cdb_3_pc==dispatching_inst_1[15:0])) ||
				(rs_1_src_0 == 4 && cdb_4[16] && ~(cdb_4_pc==dispatching_inst_1[15:0])) ||
				(rs_1_src_0 == 5 && cdb_5[16] && ~(cdb_5_pc==dispatching_inst_1[15:0])) ||
				(rs_1_src_0 == 6 && cdb_6[16] && ~(cdb_6_pc==dispatching_inst_1[15:0])));
    wire rs_1_src_1_is_on_cdb = ((rs_1_src_1 == 1 && cdb_1[16] && ~(cdb_1_pc==dispatching_inst_1[15:0])) ||
				(rs_1_src_1 == 2 && cdb_2[16] && ~(cdb_2_pc==dispatching_inst_1[15:0])) ||
				(rs_1_src_1 == 3 && cdb_3[16] && ~(cdb_3_pc==dispatching_inst_1[15:0])) ||
				(rs_1_src_1 == 4 && cdb_4[16] && ~(cdb_4_pc==dispatching_inst_1[15:0])) ||
				(rs_1_src_1 == 5 && cdb_5[16] && ~(cdb_5_pc==dispatching_inst_1[15:0])) ||
				(rs_1_src_1 == 6 && cdb_6[16] && ~(cdb_6_pc==dispatching_inst_1[15:0])));
    wire [15:0]rs_1_src_0 = dispatch_0_writing_to_us_0 ? dispatch_destination_0 :
			    register_who(reg_file[dispatching_inst_1[27:24]]);
    wire [15:0]rs_1_src_1 = dispatch_0_writing_to_us_1 ? dispatch_destination_0 :
			    register_who(reg_file[dispatching_inst_1[23:20]]);
    wire [15:0]rs_1_src_or_data_0 = (rs_1_is_src_or_data_0) ? rs_1_src_0 : rs_1_data_0;
    wire [15:0]rs_1_src_or_data_1 = (rs_1_is_src_or_data_1) ? rs_1_src_1 : rs_1_data_1;
    wire [3:0]rs_1_reg_0 = dispatching_inst_1[27:24];
    wire [3:0]rs_1_reg_1 = dispatching_inst_1[23:20];
    wire rs_entry_1_ready = (is_mov(dispatching_inst_1) || is_ld(dispatching_inst_1)) ? 1 :
                            (has_two_src(dispatching_inst_1)) ? ~(rs_1_is_src_0 || rs_1_is_src_1) :   
                            ~(reservation_valid(ld_rs_0) || reservation_valid(ld_rs_1) || reservation_valid(fx_rs_0) || reservation_valid(fx_rs_1));
    wire[15:0]rs_1_data_0 = (rs_1_src_0==1&&rs_1_src_0_is_on_cdb) ? cdb_1[15:0] :
			    (rs_1_src_0==2&&rs_1_src_0_is_on_cdb) ? cdb_2[15:0] :
			    (rs_1_src_0==3&&rs_1_src_0_is_on_cdb) ? cdb_3[15:0] :
			    (rs_1_src_0==4&&rs_1_src_0_is_on_cdb) ? cdb_4[15:0] :
			    (rs_1_src_0==5&&rs_1_src_0_is_on_cdb) ? cdb_5[15:0] :
			    (rs_1_src_0==6&&rs_1_src_0_is_on_cdb) ? cdb_6[15:0] : reg_file[dispatching_inst_1[27:24]][15:0];
    wire[15:0]rs_1_data_1 = (rs_1_src_1==1&&rs_1_src_1_is_on_cdb) ? cdb_1[15:0] :
			    (rs_1_src_1==2&&rs_1_src_1_is_on_cdb) ? cdb_2[15:0] :
			    (rs_1_src_1==3&&rs_1_src_1_is_on_cdb) ? cdb_3[15:0] :
			    (rs_1_src_1==4&&rs_1_src_1_is_on_cdb) ? cdb_4[15:0] :
			    (rs_1_src_1==5&&rs_1_src_1_is_on_cdb) ? cdb_5[15:0] :
			    (rs_1_src_1==6&&rs_1_src_1_is_on_cdb) ? cdb_6[15:0] : reg_file[dispatching_inst_1[23:20]][15:0];

    //Check to see if we will be storing data, or a src to find the data
    wire dispatch_0_writing_to_us_0 = has_two_src(dispatching_inst_1) && get_dest(instruction_from_rs(dispatching_inst_0)) == rs_1_reg_0;
    wire dispatch_0_writing_to_us_1 = has_two_src(dispatching_inst_1) && get_dest(instruction_from_rs(dispatching_inst_0)) == rs_1_reg_1;

    wire rs_1_is_src_or_data_0 = rs_1_is_src_0 || dispatch_0_writing_to_us_0;
    wire rs_1_is_src_or_data_1 = rs_1_is_src_1 || dispatch_0_writing_to_us_1;
    wire [67:0]rs_entry_1 =  (has_two_src(dispatching_inst_1)) ? ((1<<67) |
                                                                (rs_entry_1_ready<<66) |
                                                                (rs_1_is_src_or_data_0<<65) |
                                                                (rs_1_is_src_or_data_1<<64) |
                                                                (rs_1_src_or_data_0<<48) |
                                                                (rs_1_src_or_data_1<<32) |
                                                                dispatching_inst_1) : ((1<<67) | (rs_entry_1_ready<<66) | dispatching_inst_1);

    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    |	     Done  dispatching insts		    | 
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/



    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    |	      Start executing the units		    | 
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

//Execute LDU 0
    //figure out if our RS is valid. If not, see if we can forward the value here
    wire [67:0]ldu_0_entry = reservation_valid(ld_rs_0) ? ld_rs_0 : 
			     dispatch_destination_0 == 1 ? rs_entry_0 :
                             dispatch_destination_1 == 1 ? rs_entry_1 : 0;

    wire [31:0]ldu_0_inst = ldu_0_entry[31:0];
    //Look on the cdb to see if any of our sources are writing
    wire [16:0] ldu_0_src_0_on_cdb = (waiting_on_0(ldu_0_entry) == 1) ? cdb_1 : 
                                 (waiting_on_0(ldu_0_entry) == 2) ? cdb_2 :   
                                 (waiting_on_0(ldu_0_entry) == 3) ? cdb_3 :   
                                 (waiting_on_0(ldu_0_entry) == 4) ? cdb_4 :   
                                 (waiting_on_0(ldu_0_entry) == 5) ? cdb_5 : 0;

    wire [16:0] ldu_0_src_1_on_cdb = (waiting_on_1(ldu_0_entry) == 1) ? cdb_1 : 
                                 (waiting_on_1(ldu_0_entry) == 2) ? cdb_2 :   
                                 (waiting_on_1(ldu_0_entry) == 3) ? cdb_3 :   
                                 (waiting_on_1(ldu_0_entry) == 4) ? cdb_4 :   
                                 (waiting_on_1(ldu_0_entry) == 5) ? cdb_5 : 0;
    wire [15:0] ldu_0_next_waiting_on_0 = (is_rs_src_or_data_0(ldu_0_entry)&&ldu_0_src_0_on_cdb[16])?ldu_0_src_0_on_cdb[15:0] : waiting_on_0(ldu_0_entry);
    wire [15:0] ldu_0_next_waiting_on_1 = (is_rs_src_or_data_1(ldu_0_entry)&&ldu_0_src_1_on_cdb[16])?ldu_0_src_1_on_cdb[15:0] : waiting_on_1(ldu_0_entry);
    wire ldu_0_next_is_src_0 = ldu_0_next_waiting_on_0 == waiting_on_0(ldu_0_entry) && is_rs_src_or_data_0(ldu_0_entry);
    wire ldu_0_next_is_src_1 = ldu_0_next_waiting_on_1 == waiting_on_1(ldu_0_entry) && is_rs_src_or_data_1(ldu_0_entry);

    wire [15:0]ldu_0_load_from = is_ld(ldu_0_entry) ? get_immediate(ldu_0_entry) : ldu_0_next_waiting_on_0 + ldu_0_next_waiting_on_1;
    wire ldu_0_load_enabled = ldu_0_is_loading ? 0 :
			      is_ld(ldu_0_entry) || (is_ldr(ldu_0_entry)&&~(ldu_0_next_is_src_0||ldu_0_next_is_src_1));
    //the 17 bits data wires are 1 valid bit and 16 data bits
    wire [16:0]ldu_0_data_0 = loadReady0 ? (1<<16 | loadOut0) : 0;

//Execute LDU 1
    //figure out if our RS is valid. If not, see if we can forward the value here
    wire [67:0]ldu_1_entry = reservation_valid(ld_rs_1) ? ld_rs_1 : 
			     dispatch_destination_0 == 2 ? rs_entry_0 :
                             dispatch_destination_1 == 2 ? rs_entry_1 : 0;

    wire [31:0]ldu_1_inst = ldu_1_entry[31:0];
    //Look on the cdb to see if any of our sources are writing
    wire [16:0] ldu_1_src_0_on_cdb = (waiting_on_0(ldu_1_entry) == 1) ? cdb_1 : 
                                 (waiting_on_0(ldu_1_entry) == 2) ? cdb_2 :   
                                 (waiting_on_0(ldu_1_entry) == 3) ? cdb_3 :   
                                 (waiting_on_0(ldu_1_entry) == 4) ? cdb_4 :   
                                 (waiting_on_0(ldu_1_entry) == 5) ? cdb_5 : 0;

    wire [16:0] ldu_1_src_1_on_cdb = (waiting_on_1(ldu_1_entry) == 1) ? cdb_1 : 
                                 (waiting_on_1(ldu_1_entry) == 2) ? cdb_2 :   
                                 (waiting_on_1(ldu_1_entry) == 3) ? cdb_3 :   
                                 (waiting_on_1(ldu_1_entry) == 4) ? cdb_4 :   
                                 (waiting_on_1(ldu_1_entry) == 5) ? cdb_5 : 0;
    wire [15:0] ldu_1_next_waiting_on_0 = (is_rs_src_or_data_0(ldu_1_entry)&&ldu_1_src_0_on_cdb[16])?ldu_1_src_0_on_cdb[15:0] : waiting_on_0(ldu_1_entry);
    wire [15:0] ldu_1_next_waiting_on_1 = (is_rs_src_or_data_1(ldu_1_entry)&&ldu_1_src_1_on_cdb[16])?ldu_1_src_1_on_cdb[15:0] : waiting_on_1(ldu_1_entry);
    wire ldu_1_next_is_src_0 = ldu_1_next_waiting_on_0 == waiting_on_0(ldu_1_entry) && is_rs_src_or_data_0(ldu_1_entry);
    wire ldu_1_next_is_src_1 = ldu_1_next_waiting_on_1 == waiting_on_1(ldu_1_entry) && is_rs_src_or_data_1(ldu_1_entry);

    wire [15:0]ldu_1_load_from = is_ld(ldu_1_entry) ? get_immediate(ldu_1_entry) : ldu_1_next_waiting_on_0 + ldu_1_next_waiting_on_1;
    wire ldu_1_load_enabled = ldu_1_is_loading ? 0 :
			      is_ld(ldu_1_entry) || (is_ldr(ldu_1_entry)&&~(ldu_1_next_is_src_0||ldu_1_next_is_src_1));
    //the 17 bits data wires are 1 valid bit and 16 data bits
    wire [16:0]ldu_1_data_0 = loadReady1 ? (1<<16 | loadOut1) : 0;

//Execute FXU 0
    //figure out if our RS is valid. If not, see if we can forward the value here
    wire [67:0]fxu_0_entry = reservation_valid(fx_rs_0) ? fx_rs_0 : 
			     dispatch_destination_0 == 3 ? rs_entry_0 :
                             dispatch_destination_1 == 3 ? rs_entry_1 : 0;

    wire [31:0]fxu_0_inst = fxu_0_entry[31:0];
    //Look on the cdb to see if any of our sources are writing
    wire [16:0] fxu_0_src_0_on_cdb = (waiting_on_0(fxu_0_entry) == 1) ? cdb_1 : 
                                 (waiting_on_0(fxu_0_entry) == 2) ? cdb_2 :   
                                 (waiting_on_0(fxu_0_entry) == 3) ? cdb_3 :   
                                 (waiting_on_0(fxu_0_entry) == 4) ? cdb_4 :   
                                 (waiting_on_0(fxu_0_entry) == 5) ? cdb_5 : 0;

    wire [16:0] fxu_0_src_1_on_cdb = (waiting_on_1(fxu_0_entry) == 1) ? cdb_1 : 
                                 (waiting_on_1(fxu_0_entry) == 2) ? cdb_2 :   
                                 (waiting_on_1(fxu_0_entry) == 3) ? cdb_3 :   
                                 (waiting_on_1(fxu_0_entry) == 4) ? cdb_4 :   
                                 (waiting_on_1(fxu_0_entry) == 5) ? cdb_5 : 0;

    wire [15:0]fxu_0_next_waiting_on_0 = (is_rs_src_or_data_0(fxu_0_entry)&&fxu_0_src_0_on_cdb[16]) ? fxu_0_src_0_on_cdb[15:0] : waiting_on_0(fxu_0_entry);
    wire [15:0]fxu_0_next_waiting_on_1 = (is_rs_src_or_data_1(fxu_0_entry)&&fxu_0_src_1_on_cdb[16]) ? fxu_0_src_1_on_cdb[15:0] : waiting_on_1(fxu_0_entry);
    wire fxu_0_next_is_src_0 = (is_rs_src_or_data_0(fxu_0_entry)&&~fxu_0_src_0_on_cdb[16]);
    wire fxu_0_next_is_src_1 = (is_rs_src_or_data_1(fxu_0_entry)&&~fxu_0_src_1_on_cdb[16]);
    //the 17 bits data wires are 1 valid bit and 16 data bits
    //These are the two data wires to use if we are an add
    wire [16:0]fxu_0_data_0 = ~(is_rs_src_or_data_0(fxu_0_entry)) ? ((1<<16) | waiting_on_0(fxu_0_entry)) : fxu_0_src_0_on_cdb;
    wire [16:0]fxu_0_data_1 = ~(is_rs_src_or_data_1(fxu_0_entry)) ? ((1<<16) | waiting_on_1(fxu_0_entry)) : fxu_0_src_1_on_cdb;
    //Use this data wire if we are a mov
    wire [16:0]fxu_0_data_2 = fxu_0_entry[67] ? (1<<16) | get_immediate(fxu_0_entry) : 0;
    //decide what our final data looks like
    wire [16:0]fxu_0_data = (is_add(fxu_0_entry[31:0])) ? (((fxu_0_data_0[16] && fxu_0_data_1[16])<<16) | 
							   ((fxu_0_data_0[15:0] + fxu_0_data_1[15:0]))) :
                            (is_sub(fxu_0_entry[31:0])) ? (((fxu_0_data_0[16] && fxu_0_data_1[16])<<16) |
                               ((fxu_0_data_0[15:0] - fxu_0_data_1[15:0]))) :
                            (is_mul(fxu_0_entry[31:0])) ? (((fxu_0_data_0[16] && fxu_0_data_1[16])<<16) |
                                ((fxu_0_data_0[15:0] * fxu_0_data_1[15:0]))) :
                            (is_div(fxu_0_entry[31:0])) ? (((fxu_0_data_0[16] && fxu_0_data_1[16])<<16) |
                                ((fxu_0_data_0[15:0] / fxu_0_data_1[15:0]))) :
							  (fxu_0_data_2);

//Execute FXU 1
    //figure out if our RS is valid. If not, see if we can forward the value here
    wire [67:0]fxu_1_entry = reservation_valid(fx_rs_1) ? fx_rs_1 :
                             dispatch_destination_0 == 4 ? rs_entry_0 :
                             dispatch_destination_1 == 4 ? rs_entry_1 : 0;

    wire [31:0]fxu_1_inst = fxu_1_entry[31:0];
    //Look on the cdb to see if any of our sources are writing
    wire [16:0] fxu_1_src_0_on_cdb = (waiting_on_0(fxu_1_entry) == 1) ? cdb_1 : 
                                 (waiting_on_0(fxu_1_entry) == 2) ? cdb_2 :   
                                 (waiting_on_0(fxu_1_entry) == 3) ? cdb_3 :   
                                 (waiting_on_0(fxu_1_entry) == 4) ? cdb_4 :   
                                 (waiting_on_0(fxu_1_entry) == 5) ? cdb_5 : 0;

    wire [16:0] fxu_1_src_1_on_cdb = (waiting_on_1(fxu_1_entry) == 1) ? cdb_1 : 
                                 (waiting_on_1(fxu_1_entry) == 2) ? cdb_2 :   
                                 (waiting_on_1(fxu_1_entry) == 3) ? cdb_3 :   
                                 (waiting_on_1(fxu_1_entry) == 4) ? cdb_4 :   
                                 (waiting_on_1(fxu_1_entry) == 5) ? cdb_5 : 0;

    wire [15:0]fxu_1_next_waiting_on_0 = (is_rs_src_or_data_0(fxu_1_entry)&&fxu_1_src_0_on_cdb[16]) ? fxu_1_src_0_on_cdb[15:0] : waiting_on_0(fxu_1_entry);
    wire [15:0]fxu_1_next_waiting_on_1 = (is_rs_src_or_data_1(fxu_1_entry)&&fxu_1_src_1_on_cdb[16]) ? fxu_1_src_1_on_cdb[15:0] : waiting_on_1(fxu_1_entry);
    wire fxu_1_next_is_src_0 = (is_rs_src_or_data_0(fxu_1_entry)&&~fxu_1_src_0_on_cdb[16]);
    wire fxu_1_next_is_src_1 = (is_rs_src_or_data_1(fxu_1_entry)&&~fxu_1_src_1_on_cdb[16]);
    //the 17 bits data wires are 1 valid bit and 16 data bits
    //These are the two data wires to use if we are an add
    wire [16:0]fxu_1_data_0 = ~(is_rs_src_or_data_0(fxu_1_entry)) ? ((1<<16) | waiting_on_0(fxu_1_entry)) : fxu_1_src_0_on_cdb;
    wire [16:0]fxu_1_data_1 = ~(is_rs_src_or_data_1(fxu_1_entry)) ? ((1<<16) | waiting_on_1(fxu_1_entry)) : fxu_1_src_1_on_cdb;
    //Use this data wire if we are a mov
    wire [16:0]fxu_1_data_2 = fxu_1_entry[67] ? (1<<16) | get_immediate(fxu_1_entry) : 0;
    //decide what our final data looks like
    wire [16:0]fxu_1_data = (is_add(fxu_1_entry[31:0])) ? (((fxu_1_data_0[16] && fxu_1_data_1[16])<<16) |
                                                           ((fxu_1_data_0[15:0] + fxu_1_data_1[15:0]))) :
                            (is_sub(fxu_1_entry[31:0])) ? (((fxu_1_data_0[16] && fxu_1_data_1[16])<<16) |
                                                           ((fxu_1_data_0[15:0] - fxu_1_data_1[15:0]))) :
                            (is_mul(fxu_0_entry[31:0])) ? (((fxu_1_data_0[16] && fxu_1_data_1[16])<<16) |
                                                           ((fxu_1_data_0[15:0] * fxu_1_data_1[15:0]))) :
                            (is_div(fxu_0_entry[31:0])) ? (((fxu_1_data_0[16] && fxu_1_data_1[16])<<16) |
                                                           ((fxu_1_data_0[15:0] / fxu_1_data_1[15:0]))) :
                                                          (fxu_1_data_2);

//Branch Unit
    //figure out if our RS is valid. If not, see if we can forward the value here
    wire [67:0]branch_entry = reservation_valid(branch_rs) ? branch_rs : 
			     dispatch_destination_0 == 5 ? rs_entry_0 :
                             dispatch_destination_1 == 5 ? rs_entry_1 : 0;

    wire [31:0]branch_inst = branch_entry[31:0];
    //Look on the cdb to see if any of our sources are writing
    wire [16:0] branch_src_0_on_cdb = (waiting_on_0(branch_entry) == 1) ? cdb_1 : 
                                 (waiting_on_0(branch_entry) == 2) ? cdb_2 :   
                                 (waiting_on_0(branch_entry) == 3) ? cdb_3 :   
                                 (waiting_on_0(branch_entry) == 4) ? cdb_4 :   
                                 (waiting_on_0(branch_entry) == 5) ? cdb_5 : 0;

    wire [16:0] branch_src_1_on_cdb = (waiting_on_1(branch_entry) == 1) ? cdb_1 : 
                                 (waiting_on_1(branch_entry) == 2) ? cdb_2 :   
                                 (waiting_on_1(branch_entry) == 3) ? cdb_3 :   
                                 (waiting_on_1(branch_entry) == 4) ? cdb_4 :   
                                 (waiting_on_1(branch_entry) == 5) ? cdb_5 : 0;
    wire [15:0] branch_next_waiting_on_0 = (is_rs_src_or_data_0(branch_entry)&&branch_src_0_on_cdb[16])?branch_src_0_on_cdb[15:0] : waiting_on_0(branch_entry);
    wire [15:0] branch_next_waiting_on_1 = (is_rs_src_or_data_1(branch_entry)&&branch_src_1_on_cdb[16])?branch_src_1_on_cdb[15:0] : waiting_on_1(branch_entry);
    wire branch_next_is_src_0 = is_halt(branch_entry) ? 1 :
				branch_next_waiting_on_0 == waiting_on_0(branch_entry) && is_rs_src_or_data_0(branch_entry);
    wire branch_next_is_src_1 = is_halt(branch_entry) ? 1 :
				branch_next_waiting_on_1 == waiting_on_1(branch_entry) && is_rs_src_or_data_1(branch_entry);

    wire other_rs_empty = ~(reservation_valid(ld_rs_0)||reservation_valid(ld_rs_1)||reservation_valid(fx_rs_0)||reservation_valid(fx_rs_1)); 
    wire branch_is_done = reservation_valid(branch_entry)&&~(branch_next_is_src_0||branch_next_is_src_1)&&other_rs_empty;
    wire data_equal = (branch_next_waiting_on_0 == branch_next_waiting_on_1);
    wire jeq_ready = ~(branch_next_is_src_0||branch_next_is_src_1)&&reservation_valid(branch_entry);
    wire [16:0]jeq_data = data_equal ? (1<<16|branch_entry[15:0]+get_dest(branch_entry)) : 0;
    wire [15:0]branch_immediate = (branch_entry[27:16]);
    wire [17:0]branch_data = ~other_rs_empty ? 0 :
			    is_jmp(branch_entry) ? (1<<16|branch_immediate) :
			    is_jeq(branch_entry) ? (jeq_ready ? (1<<17|jeq_data) : 0) : 0;

    //the 17 bits data wires are 1 valid bit and 16 data bits

//Print Unit
    //figure out if our RS is valid. If not, see if we can forward the value here
    wire [67:0]print_entry = reservation_valid(print_rs) ? print_rs :
                             dispatch_destination_0 == 6 ? rs_entry_0 :
                             dispatch_destination_1 == 6 ? rs_entry_1 : 0;

    wire [31:0]print_inst = print_entry[31:0];
    //Look on the cdb to see if any of our sources are writing
    wire [16:0] print_src_0_on_cdb = (waiting_on_0(print_entry) == 1) ? cdb_1 :
                                     (waiting_on_0(print_entry) == 2) ? cdb_2 :
                      		     (waiting_on_0(print_entry) == 3) ? cdb_3 :
                                     (waiting_on_0(print_entry) == 4) ? cdb_4 :
                                     (waiting_on_0(print_entry) == 5) ? cdb_5 : 0;
    wire [16:0] print_src_1_on_cdb = (waiting_on_1(print_entry) == 1) ? cdb_1 :
                                     (waiting_on_1(print_entry) == 2) ? cdb_2 :
                      		     (waiting_on_1(print_entry) == 3) ? cdb_3 :
                                     (waiting_on_1(print_entry) == 4) ? cdb_4 :
                                     (waiting_on_1(print_entry) == 5) ? cdb_5 : 0;

    wire [15:0]print_next_waiting_on_0 = (is_rs_src_or_data_0(print_entry)&&print_src_0_on_cdb[16]) ? print_src_0_on_cdb[15:0] : waiting_on_0(print_entry);
    wire [15:0]print_next_waiting_on_1 = (is_rs_src_or_data_1(print_entry)&&print_src_1_on_cdb[16]) ? print_src_1_on_cdb[15:0] : waiting_on_1(print_entry);
    wire print_next_is_src_0 = (is_rs_src_or_data_0(print_entry)&&~print_src_0_on_cdb[16]);
    wire print_next_is_src_1 = (is_rs_src_or_data_1(print_entry)&&~print_src_1_on_cdb[16]);
    //the 17 bits data wires are 1 valid bit and 16 data bits
    wire [16:0]print_data = ~(is_rs_src_or_data_0(print_entry) || is_rs_src_or_data_1(print_entry))&&reservation_valid(print_entry) ? ((1<<16) | waiting_on_0(print_entry)) : print_src_0_on_cdb;

    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    |	     Done executing units		    | 
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    |	 Misc wires for updating register file      | 
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    //I'm so sorry for this monstrosity
    wire [2:0]reg_0_old_who = reg_file[0][18:16];
    wire [2:0]reg_1_old_who = reg_file[1][18:16];
    wire [2:0]reg_2_old_who = reg_file[2][18:16];
    wire [2:0]reg_3_old_who = reg_file[3][18:16];
    wire [2:0]reg_4_old_who = reg_file[4][18:16];
    wire [2:0]reg_5_old_who = reg_file[5][18:16];
    wire [2:0]reg_6_old_who = reg_file[6][18:16];
    wire [2:0]reg_7_old_who = reg_file[7][18:16];
    wire [2:0]reg_8_old_who = reg_file[8][18:16];
    wire [2:0]reg_9_old_who = reg_file[9][18:16];
    wire [2:0]reg_10_old_who = reg_file[10][18:16];
    wire [2:0]reg_11_old_who = reg_file[11][18:16];
    wire [2:0]reg_12_old_who = reg_file[12][18:16];
    wire [2:0]reg_13_old_who = reg_file[13][18:16];
    wire [2:0]reg_14_old_who = reg_file[14][18:16];
    wire [2:0]reg_15_old_who = reg_file[15][18:16];

    wire [32:0]inst_dispatching_reg_0 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==0))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==0))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_1 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==1))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==1))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_2 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==2))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==2))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_3 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==3))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==3))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_4 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==4))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==4))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_5 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==5))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==5))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_6 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==6))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==6))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_7 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==7))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==7))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_8 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==8))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==8))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_9 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==9))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==9))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_10 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==10))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==10))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_11 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==11))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==11))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_12 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==12))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==12))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_13 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==13))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==13))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_14 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==14))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==14))?(1<<32|dispatching_inst_0):0;
    wire [32:0]inst_dispatching_reg_15 = (~(dispatch_destination_1==0||dispatch_destination_1==5)&&(get_dest(dispatching_inst_1)==15))?(1<<32|dispatching_inst_1):
                                      (~(dispatch_destination_0==0||dispatch_destination_0==5)&&(get_dest(dispatching_inst_0)==15))?(1<<32|dispatching_inst_0):0;

    wire [2:0]inst_dispatching_reg_0_dest = (inst_dispatching_reg_0[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_0[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_1_dest = (inst_dispatching_reg_1[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_1[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_2_dest = (inst_dispatching_reg_2[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_2[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_3_dest = (inst_dispatching_reg_3[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_3[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_4_dest = (inst_dispatching_reg_4[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_4[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_5_dest = (inst_dispatching_reg_5[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_5[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_6_dest = (inst_dispatching_reg_6[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_6[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_7_dest = (inst_dispatching_reg_7[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_7[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_8_dest = (inst_dispatching_reg_8[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_8[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_9_dest = (inst_dispatching_reg_9[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_9[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_10_dest = (inst_dispatching_reg_10[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_10[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_11_dest = (inst_dispatching_reg_11[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_11[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_12_dest = (inst_dispatching_reg_12[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_12[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_13_dest = (inst_dispatching_reg_13[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_13[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_14_dest = (inst_dispatching_reg_14[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_14[31:0]==dispatching_inst_1)?dispatch_destination_1:0;
    wire [2:0]inst_dispatching_reg_15_dest = (inst_dispatching_reg_15[31:0]==dispatching_inst_0)?dispatch_destination_0:
                                              (inst_dispatching_reg_15[31:0]==dispatching_inst_1)?dispatch_destination_1:0;

    wire [16:0]dispatch_0_exec_now =   (inst_dispatching_reg_0==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_0[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_0[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_0[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_0[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_0[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_0[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_1_exec_now =   (inst_dispatching_reg_1==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_1[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_1[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_1[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_1[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_1[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_1[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_2_exec_now =   (inst_dispatching_reg_2==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_2[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_2[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_2[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_2[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_2[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_2[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_3_exec_now =   (inst_dispatching_reg_3==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_3[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_3[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_3[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_3[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_3[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_3[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_4_exec_now =   (inst_dispatching_reg_4==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_4[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_4[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_4[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_4[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_4[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_4[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_5_exec_now =   (inst_dispatching_reg_5==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_5[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_5[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_5[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_5[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_5[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_5[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_6_exec_now =   (inst_dispatching_reg_6==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_6[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_6[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_6[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_6[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_6[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_6[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_7_exec_now =   (inst_dispatching_reg_7==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_7[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_7[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_7[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_7[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_7[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_7[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_8_exec_now =   (inst_dispatching_reg_8==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_8[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_8[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_8[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_8[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_8[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_8[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_9_exec_now =   (inst_dispatching_reg_9==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_9[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_9[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_9[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_9[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_9[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_9[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_10_exec_now =   (inst_dispatching_reg_10==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_10[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_10[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_10[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_10[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_10[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_10[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_11_exec_now =   (inst_dispatching_reg_11==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_11[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_11[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_11[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_11[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_11[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_11[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_12_exec_now =   (inst_dispatching_reg_12==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_12[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_12[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_12[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_12[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_12[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_12[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_13_exec_now =   (inst_dispatching_reg_13==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_13[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_13[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_13[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_13[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_13[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_13[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_14_exec_now =   (inst_dispatching_reg_14==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_14[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_14[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_14[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_14[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_14[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_14[15:0]==cdb_6_pc)?cdb_6:0;
     wire [16:0]dispatch_15_exec_now =   (inst_dispatching_reg_15==0) ? 0 :
                                  (cdb_1[16]&&inst_dispatching_reg_15[15:0]==cdb_1_pc)?cdb_1:(cdb_2[16]&&inst_dispatching_reg_15[15:0]==cdb_2_pc)?cdb_2:
                                  (cdb_3[16]&&inst_dispatching_reg_15[15:0]==cdb_3_pc)?cdb_3:(cdb_4[16]&&inst_dispatching_reg_15[15:0]==cdb_4_pc)?cdb_4:
                                  (cdb_5[16]&&inst_dispatching_reg_15[15:0]==cdb_5_pc)?cdb_5:(cdb_6[16]&&inst_dispatching_reg_15[15:0]==cdb_6_pc)?cdb_6:0;

    wire [16:0]old_who_0_exec_now = (cdb_1[16]&&reg_0_old_who==1)?cdb_1:(cdb_2[16]&&reg_0_old_who==2)?cdb_2:(cdb_3[16]&&reg_0_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_0_old_who==4)?cdb_4:(cdb_5[16]&&reg_0_old_who==5)?cdb_5:(cdb_6[16]&&reg_0_old_who==6)?cdb_6:0;
    wire [16:0]old_who_1_exec_now = (cdb_1[16]&&reg_1_old_who==1)?cdb_1:(cdb_2[16]&&reg_1_old_who==2)?cdb_2:(cdb_3[16]&&reg_1_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_1_old_who==4)?cdb_4:(cdb_5[16]&&reg_1_old_who==5)?cdb_5:(cdb_6[16]&&reg_1_old_who==6)?cdb_6:0;
    wire [16:0]old_who_2_exec_now = (cdb_1[16]&&reg_2_old_who==1)?cdb_1:(cdb_2[16]&&reg_2_old_who==2)?cdb_2:(cdb_3[16]&&reg_2_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_2_old_who==4)?cdb_4:(cdb_5[16]&&reg_2_old_who==5)?cdb_5:(cdb_6[16]&&reg_2_old_who==6)?cdb_6:0;
    wire [16:0]old_who_3_exec_now = (cdb_1[16]&&reg_3_old_who==1)?cdb_1:(cdb_2[16]&&reg_3_old_who==2)?cdb_2:(cdb_3[16]&&reg_3_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_3_old_who==4)?cdb_4:(cdb_5[16]&&reg_3_old_who==5)?cdb_5:(cdb_6[16]&&reg_3_old_who==6)?cdb_6:0;
    wire [16:0]old_who_4_exec_now = (cdb_1[16]&&reg_4_old_who==1)?cdb_1:(cdb_2[16]&&reg_4_old_who==2)?cdb_2:(cdb_3[16]&&reg_4_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_4_old_who==4)?cdb_4:(cdb_5[16]&&reg_4_old_who==5)?cdb_5:(cdb_6[16]&&reg_4_old_who==6)?cdb_6:0;
    wire [16:0]old_who_5_exec_now = (cdb_1[16]&&reg_5_old_who==1)?cdb_1:(cdb_2[16]&&reg_5_old_who==2)?cdb_2:(cdb_3[16]&&reg_5_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_5_old_who==4)?cdb_4:(cdb_5[16]&&reg_5_old_who==5)?cdb_5:(cdb_6[16]&&reg_5_old_who==6)?cdb_6:0;
    wire [16:0]old_who_6_exec_now = (cdb_1[16]&&reg_6_old_who==1)?cdb_1:(cdb_2[16]&&reg_6_old_who==2)?cdb_2:(cdb_3[16]&&reg_6_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_6_old_who==4)?cdb_4:(cdb_5[16]&&reg_6_old_who==5)?cdb_5:(cdb_6[16]&&reg_6_old_who==6)?cdb_6:0;
    wire [16:0]old_who_7_exec_now = (cdb_1[16]&&reg_7_old_who==1)?cdb_1:(cdb_2[16]&&reg_7_old_who==2)?cdb_2:(cdb_3[16]&&reg_7_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_7_old_who==4)?cdb_4:(cdb_5[16]&&reg_7_old_who==5)?cdb_5:(cdb_6[16]&&reg_7_old_who==6)?cdb_6:0;
    wire [16:0]old_who_8_exec_now = (cdb_1[16]&&reg_8_old_who==1)?cdb_1:(cdb_2[16]&&reg_8_old_who==2)?cdb_2:(cdb_3[16]&&reg_8_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_8_old_who==4)?cdb_4:(cdb_5[16]&&reg_8_old_who==5)?cdb_5:(cdb_6[16]&&reg_8_old_who==6)?cdb_6:0;
    wire [16:0]old_who_9_exec_now = (cdb_1[16]&&reg_9_old_who==1)?cdb_1:(cdb_2[16]&&reg_9_old_who==2)?cdb_2:(cdb_3[16]&&reg_9_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_9_old_who==4)?cdb_4:(cdb_5[16]&&reg_9_old_who==5)?cdb_5:(cdb_6[16]&&reg_9_old_who==6)?cdb_6:0;
    wire [16:0]old_who_10_exec_now = (cdb_1[16]&&reg_10_old_who==1)?cdb_1:(cdb_2[16]&&reg_10_old_who==2)?cdb_2:(cdb_3[16]&&reg_10_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_10_old_who==4)?cdb_4:(cdb_5[16]&&reg_10_old_who==5)?cdb_5:(cdb_6[16]&&reg_10_old_who==6)?cdb_6:0;
    wire [16:0]old_who_11_exec_now = (cdb_1[16]&&reg_11_old_who==1)?cdb_1:(cdb_2[16]&&reg_11_old_who==2)?cdb_2:(cdb_3[16]&&reg_11_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_11_old_who==4)?cdb_4:(cdb_5[16]&&reg_11_old_who==5)?cdb_5:(cdb_6[16]&&reg_11_old_who==6)?cdb_6:0;
    wire [16:0]old_who_12_exec_now = (cdb_1[16]&&reg_12_old_who==1)?cdb_1:(cdb_2[16]&&reg_12_old_who==2)?cdb_2:(cdb_3[16]&&reg_12_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_12_old_who==4)?cdb_4:(cdb_5[16]&&reg_12_old_who==5)?cdb_5:(cdb_6[16]&&reg_12_old_who==6)?cdb_6:0;
    wire [16:0]old_who_13_exec_now = (cdb_1[16]&&reg_13_old_who==1)?cdb_1:(cdb_2[16]&&reg_13_old_who==2)?cdb_2:(cdb_3[16]&&reg_13_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_13_old_who==4)?cdb_4:(cdb_5[16]&&reg_13_old_who==5)?cdb_5:(cdb_6[16]&&reg_13_old_who==6)?cdb_6:0;
    wire [16:0]old_who_14_exec_now = (cdb_1[16]&&reg_14_old_who==1)?cdb_1:(cdb_2[16]&&reg_14_old_who==2)?cdb_2:(cdb_3[16]&&reg_14_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_14_old_who==4)?cdb_4:(cdb_5[16]&&reg_14_old_who==5)?cdb_5:(cdb_6[16]&&reg_14_old_who==6)?cdb_6:0;
    wire [16:0]old_who_15_exec_now = (cdb_1[16]&&reg_15_old_who==1)?cdb_1:(cdb_2[16]&&reg_15_old_who==2)?cdb_2:(cdb_3[16]&&reg_15_old_who==3)?cdb_3:
                              (cdb_4[16]&&reg_15_old_who==4)?cdb_4:(cdb_5[16]&&reg_15_old_who==5)?cdb_5:(cdb_6[16]&&reg_15_old_who==6)?cdb_6:0;

    wire [2:0]reg_0_next_who = (dispatch_0_exec_now[16]&&~(inst_dispatching_reg_0==0))?0:
                                 ~(inst_dispatching_reg_0==0)?inst_dispatching_reg_0_dest:
                                 (old_who_0_exec_now) ? 0 : reg_0_old_who;
    wire [2:0]reg_1_next_who = (dispatch_1_exec_now[16]&&~(inst_dispatching_reg_1==0))?0:
                                 ~(inst_dispatching_reg_1==0)?inst_dispatching_reg_1_dest:
                                 (old_who_1_exec_now) ? 0 : reg_1_old_who;
    wire [2:0]reg_2_next_who = (dispatch_2_exec_now[16]&&~(inst_dispatching_reg_2==0))?0:
                                 ~(inst_dispatching_reg_2==0)?inst_dispatching_reg_2_dest:
                                 (old_who_2_exec_now) ? 0 : reg_2_old_who;
    wire [2:0]reg_3_next_who = (dispatch_3_exec_now[16]&&~(inst_dispatching_reg_3==0))?0:
                                 ~(inst_dispatching_reg_3==0)?inst_dispatching_reg_3_dest:
                                 (old_who_3_exec_now) ? 0 : reg_3_old_who;
    wire [2:0]reg_4_next_who = (dispatch_4_exec_now[16]&&~(inst_dispatching_reg_4==0))?0:
                                 ~(inst_dispatching_reg_4==0)?inst_dispatching_reg_4_dest:
                                 (old_who_4_exec_now) ? 0 : reg_4_old_who;
    wire [2:0]reg_5_next_who = (dispatch_5_exec_now[16]&&~(inst_dispatching_reg_5==0))?0:
                                 ~(inst_dispatching_reg_5==0)?inst_dispatching_reg_5_dest:
                                 (old_who_5_exec_now) ? 0 : reg_5_old_who;
    wire [2:0]reg_6_next_who = (dispatch_6_exec_now[16]&&~(inst_dispatching_reg_6==0))?0:
                                 ~(inst_dispatching_reg_6==0)?inst_dispatching_reg_6_dest:
                                 (old_who_6_exec_now) ? 0 : reg_6_old_who;
    wire [2:0]reg_7_next_who = (dispatch_7_exec_now[16]&&~(inst_dispatching_reg_7==0))?0:
                                 ~(inst_dispatching_reg_7==0)?inst_dispatching_reg_7_dest:
                                 (old_who_7_exec_now) ? 0 : reg_7_old_who;
    wire [2:0]reg_8_next_who = (dispatch_8_exec_now[16]&&~(inst_dispatching_reg_8==0))?0:
                                 ~(inst_dispatching_reg_8==0)?inst_dispatching_reg_8_dest:
                                 (old_who_8_exec_now) ? 0 : reg_8_old_who;
    wire [2:0]reg_9_next_who = (dispatch_9_exec_now[16]&&~(inst_dispatching_reg_9==0))?0:
                                 ~(inst_dispatching_reg_9==0)?inst_dispatching_reg_9_dest:
                                 (old_who_9_exec_now) ? 0 : reg_9_old_who;
    wire [2:0]reg_10_next_who = (dispatch_10_exec_now[16]&&~(inst_dispatching_reg_10==0))?0:
                                 ~(inst_dispatching_reg_10==0)?inst_dispatching_reg_10_dest:
                                 (old_who_10_exec_now) ? 0 : reg_10_old_who;
    wire [2:0]reg_11_next_who = (dispatch_11_exec_now[16]&&~(inst_dispatching_reg_11==0))?0:
                                 ~(inst_dispatching_reg_11==0)?inst_dispatching_reg_11_dest:
                                 (old_who_11_exec_now) ? 0 : reg_11_old_who;
    wire [2:0]reg_12_next_who = (dispatch_12_exec_now[16]&&~(inst_dispatching_reg_12==0))?0:
                                 ~(inst_dispatching_reg_12==0)?inst_dispatching_reg_12_dest:
                                 (old_who_12_exec_now) ? 0 : reg_12_old_who;
    wire [2:0]reg_13_next_who = (dispatch_13_exec_now[16]&&~(inst_dispatching_reg_13==0))?0:
                                 ~(inst_dispatching_reg_13==0)?inst_dispatching_reg_13_dest:
                                 (old_who_13_exec_now) ? 0 : reg_13_old_who;
    wire [2:0]reg_14_next_who = (dispatch_14_exec_now[16]&&~(inst_dispatching_reg_14==0))?0:
                                 ~(inst_dispatching_reg_14==0)?inst_dispatching_reg_14_dest:
                                 (old_who_14_exec_now) ? 0 : reg_14_old_who;
    wire [2:0]reg_15_next_who = (dispatch_15_exec_now[16]&&~(inst_dispatching_reg_15==0))?0:
                                 ~(inst_dispatching_reg_15==0)?inst_dispatching_reg_15_dest:
                                 (old_who_15_exec_now) ? 0 : reg_15_old_who;

    wire [15:0]reg_0_next_data = (dispatch_0_exec_now[16]&&~(inst_dispatching_reg_0==0))?dispatch_0_exec_now[15:0]:
                                   (old_who_0_exec_now[16])?old_who_0_exec_now[15:0]:reg_file[0][15:0];
    wire [15:0]reg_1_next_data = (dispatch_1_exec_now[16]&&~(inst_dispatching_reg_1==0))?dispatch_1_exec_now[15:0]:
                                   (old_who_1_exec_now[16])?old_who_1_exec_now[15:0]:reg_file[1][15:0];
    wire [15:0]reg_2_next_data = (dispatch_2_exec_now[16]&&~(inst_dispatching_reg_2==0))?dispatch_2_exec_now[15:0]:
                                   (old_who_2_exec_now[16])?old_who_2_exec_now[15:0]:reg_file[2][15:0];
    wire [15:0]reg_3_next_data = (dispatch_3_exec_now[16]&&~(inst_dispatching_reg_3==0))?dispatch_3_exec_now[15:0]:
                                   (old_who_3_exec_now[16])?old_who_3_exec_now[15:0]:reg_file[3][15:0];
    wire [15:0]reg_4_next_data = (dispatch_4_exec_now[16]&&~(inst_dispatching_reg_4==0))?dispatch_4_exec_now[15:0]:
                                   (old_who_4_exec_now[16])?old_who_4_exec_now[15:0]:reg_file[4][15:0];
    wire [15:0]reg_5_next_data = (dispatch_5_exec_now[16]&&~(inst_dispatching_reg_5==0))?dispatch_5_exec_now[15:0]:
                                   (old_who_5_exec_now[16])?old_who_5_exec_now[15:0]:reg_file[5][15:0];
    wire [15:0]reg_6_next_data = (dispatch_6_exec_now[16]&&~(inst_dispatching_reg_6==0))?dispatch_6_exec_now[15:0]:
                                   (old_who_6_exec_now[16])?old_who_6_exec_now[15:0]:reg_file[6][15:0];
    wire [15:0]reg_7_next_data = (dispatch_7_exec_now[16]&&~(inst_dispatching_reg_7==0))?dispatch_7_exec_now[15:0]:
                                   (old_who_7_exec_now[16])?old_who_7_exec_now[15:0]:reg_file[7][15:0];
    wire [15:0]reg_8_next_data = (dispatch_8_exec_now[16]&&~(inst_dispatching_reg_8==0))?dispatch_8_exec_now[15:0]:
                                   (old_who_8_exec_now[16])?old_who_8_exec_now[15:0]:reg_file[8][15:0];
    wire [15:0]reg_9_next_data = (dispatch_9_exec_now[16]&&~(inst_dispatching_reg_9==0))?dispatch_9_exec_now[15:0]:
                                   (old_who_9_exec_now[16])?old_who_9_exec_now[15:0]:reg_file[9][15:0];
    wire [15:0]reg_10_next_data = (dispatch_10_exec_now[16]&&~(inst_dispatching_reg_10==0))?dispatch_10_exec_now[15:0]:
                                   (old_who_10_exec_now[16])?old_who_10_exec_now[15:0]:reg_file[10][15:0];
    wire [15:0]reg_11_next_data = (dispatch_11_exec_now[16]&&~(inst_dispatching_reg_11==0))?dispatch_11_exec_now[15:0]:
                                   (old_who_11_exec_now[16])?old_who_11_exec_now[15:0]:reg_file[11][15:0];
    wire [15:0]reg_12_next_data = (dispatch_12_exec_now[16]&&~(inst_dispatching_reg_12==0))?dispatch_12_exec_now[15:0]:
                                   (old_who_12_exec_now[16])?old_who_12_exec_now[15:0]:reg_file[12][15:0];
    wire [15:0]reg_13_next_data = (dispatch_13_exec_now[16]&&~(inst_dispatching_reg_13==0))?dispatch_13_exec_now[15:0]:
                                   (old_who_13_exec_now[16])?old_who_13_exec_now[15:0]:reg_file[13][15:0];
    wire [15:0]reg_14_next_data = (dispatch_14_exec_now[16]&&~(inst_dispatching_reg_14==0))?dispatch_14_exec_now[15:0]:
                                   (old_who_14_exec_now[16])?old_who_14_exec_now[15:0]:reg_file[14][15:0];
    wire [15:0]reg_15_next_data = (dispatch_15_exec_now[16]&&~(inst_dispatching_reg_15==0))?dispatch_15_exec_now[15:0]:
                                   (old_who_15_exec_now[16])?old_who_15_exec_now[15:0]:reg_file[15][15:0];

//generate wires for the register file for debugging purposes
    wire [19:0]element0 = reg_file[0];
    wire [19:0]element1 = reg_file[1];
    wire [19:0]element2 = reg_file[2];
    wire [19:0]element3 = reg_file[3];
    wire [19:0]element4 = reg_file[4];
    wire [19:0]element5 = reg_file[5];
    wire [19:0]element6 = reg_file[6];
    wire [19:0]element7 = reg_file[7];
    wire [19:0]element8 = reg_file[8];
    wire [19:0]element9 = reg_file[9];
    wire [19:0]element10 = reg_file[10];
    wire [19:0]element11 = reg_file[11];
    wire [19:0]element12 = reg_file[12];
    wire [19:0]element13 = reg_file[13];
    wire [19:0]element14 = reg_file[14];
    wire [19:0]element15 = reg_file[15];



    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    |	     Done updating the register files	    | 
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    always @(posedge clk) begin
	pc <= (cdb_5[16]) ? cdb_5[15:0] : next_pc;	
	final_halt <= halt;

	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	|	      start updating the IBq metadata	|
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	if (fetchReady) begin
	    IBq[IBqtail] <= fetchOut << 16 | fetchOutpc;
	end
   	if (fetchReady1) begin
	    IBq[IBqtail+1] <= fetchOut1 << 16 | fetchOutpc1;
	end
	//new size is oldsize + #fetched - #dispatched
	IBqsize <= (cdb_5[16]) ? 0 :
		   IBqsize + fetchReady + fetchReady1 - (dispatch_destination_0 > 0) - (dispatch_destination_1 > 0);
	IBqtail <= (cdb_5[16]) ? 0 :
		   IBqtail + fetchReady + fetchReady1;
	IBqhead <= (cdb_5[16]) ? 0 :
		   IBqhead + (dispatch_destination_0 > 0) + (dispatch_destination_1 > 0);
	 
	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	|	     end of updating the ibq		|
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	|	     Start updating RSs			|
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

        ld_rs_0 <= (dispatch_destination_0==1&&~(cdb_1[16]&&cdb_1_pc==dispatching_inst_0[15:0])) ? rs_entry_0 :
                   (dispatch_destination_1==1&&~(cdb_1[16]&&cdb_1_pc==dispatching_inst_1[15:0])) ? rs_entry_1 :
                   cdb_1[16] ? 0 :(ld_rs_0[67:66]<<66 |          
                                  (ldu_0_next_is_src_0<<65) |    
                                  (ldu_0_next_is_src_1<<64) |    
                                  (ldu_0_next_waiting_on_0<<48) |
                                  (ldu_0_next_waiting_on_1<<32) |
                                  ld_rs_0[31:0]);
	ldu_0_is_loading <= (ldu_0_load_enabled) ? 1 :
			    (loadReady0) ? 0 : ldu_0_is_loading;

        ld_rs_1 <= (dispatch_destination_0==2&&~(cdb_2[16]&&cdb_2_pc==dispatching_inst_0[15:0])) ? rs_entry_0 :
                   (dispatch_destination_1==2&&~(cdb_2[16]&&cdb_2_pc==dispatching_inst_1[15:0])) ? rs_entry_1 :
                   cdb_2[16] ? 0 :(ld_rs_1[67:66]<<66 |          
                                  (ldu_1_next_is_src_0<<65) |    
                                  (ldu_1_next_is_src_1<<64) |    
                                  (ldu_1_next_waiting_on_0<<48) |
                                  (ldu_1_next_waiting_on_1<<32) |
                                  ld_rs_1[31:0]);
	ldu_1_is_loading <= (ldu_1_load_enabled) ? 1 :
			    (loadReady1) ? 0 : ldu_1_is_loading;

        fx_rs_0 <= (dispatch_destination_0==3&&~(cdb_3[16]&&cdb_3_pc==dispatching_inst_0[15:0])) ? rs_entry_0 :
                   (dispatch_destination_1==3&&~(cdb_3[16]&&cdb_3_pc==dispatching_inst_1[15:0])) ? rs_entry_1 :
                   cdb_3[16] ? 0 :(fx_rs_0[67:66]<<66 |          
                                  (fxu_0_next_is_src_0<<65) |    
                                  (fxu_0_next_is_src_1<<64) |    
                                  (fxu_0_next_waiting_on_0<<48) |
                                  (fxu_0_next_waiting_on_1<<32) |
                                  fx_rs_0[31:0]); 

        fx_rs_1 <= (dispatch_destination_0==4&&~(cdb_4[16]&&cdb_4_pc==dispatching_inst_0[15:0])) ? rs_entry_0 :
                   (dispatch_destination_1==4&&~(cdb_4[16]&&cdb_4_pc==dispatching_inst_1[15:0])) ? rs_entry_1 :
                   cdb_4[16] ? 0 :(fx_rs_1[67:66]<<66 |          
                                  (fxu_1_next_is_src_0<<65) |    
                                  (fxu_1_next_is_src_1<<64) |    
                                  (fxu_1_next_waiting_on_0<<48) |
                                  (fxu_1_next_waiting_on_1<<32) |
                                  fx_rs_1[31:0]); 
 
        branch_rs <= (cdb_5[16]||cdb_5[17]) ? 0 :
                   dispatch_destination_0 == 5 ? rs_entry_0 :
                   dispatch_destination_1 == 5 ? rs_entry_1 :(branch_rs[67:66]<<66 |          
							     (branch_next_is_src_0<<65) |
							     (branch_next_is_src_1<<64) |
							     (branch_next_waiting_on_0<<48) |
							     (branch_next_waiting_on_1<<32) |
							     branch_rs[31:0]);
        
	print_rs <= (dispatch_destination_0==6&&~(cdb_6[16]&&cdb_6_pc==dispatching_inst_0[15:0])) ? rs_entry_0 :
                   (dispatch_destination_1==6&&~(cdb_6[16]&&cdb_6_pc==dispatching_inst_1[15:0])) ? rs_entry_1 :
                   cdb_6[16] ? 0 :(print_rs[67:66]<<66 |          
                                  (print_next_is_src_0<<65) |    
                                  (print_next_is_src_1<<64) |    
                                  (print_next_waiting_on_0<<48) |
                                  (print_next_waiting_on_1<<32) |
                                  print_rs[31:0]); 
	
	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	|	     Done updating RSs			|
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	|	     Start printing print inst		|
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

	if(cdb_6[16]) begin
               $display("#%x",cdb_6[15:0]);
	end

	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	|	     Done printing print inst		|
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	|	     Start updating registers		|
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
	
	reg_file[0] <= reg_0_next_who<<16|reg_0_next_data;
	reg_file[1] <= reg_1_next_who<<16|reg_1_next_data;
    	reg_file[2] <= reg_2_next_who<<16|reg_2_next_data;
   	reg_file[3] <= reg_3_next_who<<16|reg_3_next_data;
   	reg_file[4] <= reg_4_next_who<<16|reg_4_next_data;
   	reg_file[5] <= reg_5_next_who<<16|reg_5_next_data;
   	reg_file[6] <= reg_6_next_who<<16|reg_6_next_data;
    	reg_file[7] <= reg_7_next_who<<16|reg_7_next_data;
    	reg_file[8] <= reg_8_next_who<<16|reg_8_next_data;
    	reg_file[9] <= reg_9_next_who<<16|reg_9_next_data;
    	reg_file[10] <= reg_10_next_who<<16|reg_10_next_data;
    	reg_file[11] <= reg_11_next_who<<16|reg_11_next_data;
    	reg_file[12] <= reg_12_next_who<<16|reg_12_next_data;
    	reg_file[13] <= reg_13_next_who<<16|reg_13_next_data;
    	reg_file[14] <= reg_14_next_who<<16|reg_14_next_data;
    	reg_file[15] <= reg_15_next_who<<16|reg_15_next_data;

///* This will print out the values of every register at the end of the program 
	if(halt) begin
               $display("#0:%x",reg_file[0][15:0]);
               $display("#1:%x",reg_file[1][15:0]);
               $display("#2:%x",reg_file[2][15:0]);
               $display("#3:%x",reg_file[3][15:0]);
               $display("#4:%x",reg_file[4][15:0]);
               $display("#5:%x",reg_file[5][15:0]);
               $display("#6:%x",reg_file[6][15:0]);
               $display("#7:%x",reg_file[7][15:0]);
               $display("#8:%x",reg_file[8][15:0]);
               $display("#9:%x",reg_file[9][15:0]);
               $display("#10:%x",reg_file[10][15:0]);
               $display("#11:%x",reg_file[11][15:0]);
               $display("#12:%x",reg_file[12][15:0]);
               $display("#13:%x",reg_file[13][15:0]);
               $display("#14:%x",reg_file[14][15:0]);
               $display("#15:%x",reg_file[15][15:0]);
	end
 	
	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	|	     Done updating registers		|
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    end


	/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	|	     Start of functions			|
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    //Get the instruction out of an IB entry
    function  [15:0]instruction_from_IB;
	input [31:0]IBq_data;
    	instruction_from_IB = IBq_data[31:16];
    endfunction

    //Get the pc out of an IB entry
    function  [15:0]pc_from_IB;
	input [31:0]IBq_pc;
    	pc_from_IB = IBq_pc[15:0];
    endfunction

    //Tell in an instruction is mov
    function is_mov;
	input[31:0]IBq_data;
	is_mov = IBq_data[31:28] == 0;
    endfunction

    //Tell in an instruction is add 
    function is_add;
    	input[31:0]IBq_data;
    	is_add = IBq_data[31:28] == 1;
    endfunction
    
    //Tell in an instruction is sub
    function is_sub;
        input[31:0]IBq_data;
        is_sub = IBq_data[31:28] == 7;
    endfunction

    //Tell in an instruction is mul 
    function is_mul;
        input[31:0]IBq_data;
        is_mul = IBq_data[31:28] == 9;
    endfunction

    //Tell in an instruction is sub
    function is_div;
        input[31:0]IBq_data;
        is_div = IBq_data[31:28] == 10;
    endfunction

//Tell in an instruction is jmp   
    function is_jmp;                  
        input[31:0]IBq_data;          
        is_jmp = IBq_data[31:28] == 2;
    endfunction                       
                                      
    //Tell in an instruction is halt   
    function is_halt;                  
        input[31:0]IBq_data;          
        is_halt = IBq_data[31:28] == 3;
    endfunction                       
                                      
    //Tell in an instruction is ld   
    function is_ld;                  
        input[31:0]IBq_data;          
        is_ld = IBq_data[31:28] == 4;
    endfunction                       
                                      
    //Tell in an instruction is ldr   
    function is_ldr;                  
        input[31:0]IBq_data;          
        is_ldr = IBq_data[31:28] == 5;
    endfunction                       
                                      
    //Tell in an instruction is jeq   
    function is_jeq;                  
        input[31:0]IBq_data;          
        is_jeq = IBq_data[31:28] == 6;
    endfunction

    //Tell if an instruction is a print
    function is_print;
	input[31:0]IBq_data;
	is_print = IBq_data[31:28] == 8;
    endfunction

    function is_fx;
	input[31:0]IBq_data;
	is_fx = (is_add(IBq_data) || is_sub(IBq_data) || is_mul(IBq_data) || is_div(IBq_data) || is_mov(IBq_data));
    endfunction

    function has_two_src;
	input [31:0]IBq_data;
	has_two_src = (is_add(IBq_data) || is_sub(IBq_data) || is_mul(IBq_data) || is_div(IBq_data) || is_ldr(IBq_data) || is_jeq(IBq_data) || is_print(IBq_data));
    endfunction

    function [3:0]get_dest;
	input [31:0]IBq_data;
	get_dest = IBq_data[19:16];
    endfunction

    //
    // Functions used for accessing reservation stations
    //
    function reservation_valid;
	input [67:0]rs_data;
	reservation_valid = rs_data[67];
    endfunction

    function reservation_busy;
	input [67:0]rs_data;
	reservation_busy = rs_data[66];
    endfunction

    function is_src_0;
	input [67:0]rs_data;
	is_src_0 = rs_data[65];
    endfunction

    function is_src_1;
	input [67:0]rs_data;
	is_src_1 = rs_data[64];
    endfunction

    function [15:0]waiting_on_0;
 	input [67:0]rs_data;
	waiting_on_0 = rs_data[63:48];
    endfunction

    function [15:0]waiting_on_1;
	input [67:0]rs_data;
	waiting_on_1 = rs_data[47:32];
    endfunction

    function [15:0]get_immediate;
	input [67:0]rs_data;
	get_immediate = rs_data[27:20];
    endfunction

    function [31:0]instruction_from_rs;
	input [67:0]rs_data;
	instruction_from_rs = rs_data[31:0];
    endfunction

    function reservation_ready;
	input [67:0]rs_data;
        reservation_ready = (is_mov(rs_data[31:0]) || is_ld(rs_data[31:0])) ? 1 :
                            (has_two_src(rs_data[31:0])) ? ~(is_src_or_data_0(rs_data[31:0]) || is_src_or_data_1(rs_data[31:0])) :
                            ~(reservation_valid(ld_rs_0) || reservation_valid(ld_rs_1) || reservation_valid(fx_rs_0) || reservation_valid(fx_rs_1));
    endfunction

    function is_rs_src_or_data_0;
	input [67:0]rs_data;
	is_rs_src_or_data_0 = rs_data[65];
    endfunction

    function is_rs_src_or_data_1;
	input [67:0]rs_data;
	is_rs_src_or_data_1 = rs_data[64];
    endfunction


    //
    // Functions used for accessing register files
    //
    function register_busy;
	input [19:0]register_entry;
	register_busy = register_entry[19];
    endfunction

    function [3:0]register_who;
	input [19:0]register_entry;
	register_who = register_entry[18:16];
    endfunction

    function [15:0]register_data;
	input [19:0]register_entry;
	register_data = register_entry[15:0];
    endfunction

    function [2:0]who_writing_to_register;
	input[3:0]reg_number;
	who_writing_to_register = (~(dispatch_destination_1 == 0 || dispatch_destination_1 == 5) && (get_dest(dispatching_inst_1) == reg_number)) ? 
				     dispatch_destination_1 :
    				  (~(dispatch_destination_0 == 0 || dispatch_destination_0 == 5) && (get_dest(dispatching_inst_0) == reg_number)) ? 
				     dispatch_destination_0 : 0;
    endfunction

    //
    // Functions used to create an RS entry
    //
    function is_src_or_data_0;
	input [31:0]IBq_data;
	is_src_or_data_0 = register_busy(IBq_data[27:24]);
    endfunction

    function is_src_or_data_1;
	input [31:0]IBq_data;
	is_src_or_data_1 = register_busy(IBq_data[23:20]);
    endfunction

    function [15:0]get_src_or_data_0;
	input [31:0]IBq_data;

    	get_src_or_data_0 = (is_src_or_data_0(IBq_data)) ? register_who(IBq_data[27:24]) : 
                            /*(register_being_written(IBq_data[27:24])) ? new_register_data(IBq_data[27:24]) :*/ reg_file[IBq_data[27:24]][15:0];
    endfunction

    function [15:0]get_src_or_data_1;
	input [31:0]IBq_data;

    	get_src_or_data_1 = (is_src_or_data_1(IBq_data)) ? register_who(IBq_data[23:20]) : 
                            /*(register_being_written(IBq_data[23:20])) ? new_register_data(IBq_data[23:20]) :*/ reg_file[IBq_data[23:20]][15:0];
    endfunction

    //
    // Functions for accessing the CDB
    //
    function [16:0]my_src_0_on_cdb;
  	input [67:0]rs_data;
	my_src_0_on_cdb = (waiting_on_0(rs_data) == 1) ? cdb_1 :
			(waiting_on_0(rs_data) == 2) ? cdb_2 :
			(waiting_on_0(rs_data) == 3) ? cdb_3 :
			(waiting_on_0(rs_data) == 4) ? cdb_4 :
			(waiting_on_0(rs_data) == 5) ? cdb_5 : 0;
    endfunction

    function [16:0]my_src_1_on_cdb;
  	input [67:0]rs_data;
	my_src_1_on_cdb = (waiting_on_1(rs_data) == 1) ? cdb_1 :
			(waiting_on_1(rs_data) == 2) ? cdb_2 :
			(waiting_on_1(rs_data) == 3) ? cdb_3 :
			(waiting_on_1(rs_data) == 4) ? cdb_4 :
			(waiting_on_1(rs_data) == 5) ? cdb_5 : 0;
    endfunction

    function is_new_reg_data_on_cdb;
	input [2:0]cdb_number;
        is_new_reg_data_on_cdb = ((cdb_1[16] && (cdb_number == 1))  || 
                                  (cdb_2[16] && (cdb_number == 2))  ||
                                  (cdb_3[16] && (cdb_number == 3))  ||
                                  (cdb_4[16] && (cdb_number == 4))  ||
                                  (cdb_5[16] && (cdb_number == 5))) ? 1 : 0;
    endfunction

    function [15:0]get_new_reg_data_on_cdb;
	input [2:0]cdb_number;
	get_new_reg_data_on_cdb = (cdb_number == 1) ? cdb_1[15:0] :
				  (cdb_number == 2) ? cdb_2[15:0] : 
				  (cdb_number == 3) ? cdb_3[15:0] : 
			   	  (cdb_number == 4) ? cdb_4[15:0] :
				  (cdb_number == 5) ? cdb_5[15:0] : 0;
    endfunction

endmodule
