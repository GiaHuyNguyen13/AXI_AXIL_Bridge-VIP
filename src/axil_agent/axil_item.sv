class axil_item extends uvm_sequence_item;
    `uvm_object_utils(axil_item)

   rand bit         operation; // 0 for read, 1 for write
   rand bit [7:0]   num_beats; // temp value of burst length, "Check the number of beats received, and if it's the last beat, assert m_axil_bresp."

   // Write address line
        bit [31:0]  m_axil_awaddr;
        bit [2:0]   m_axil_awprot;
        bit         m_axil_awvalid;
   rand bit         m_axil_awready;

   // Write data line
        bit [31:0]  m_axil_wdata;
        bit [3:0]   m_axil_wstrb;
        bit         m_axil_wvalid;
   rand bit         m_axil_wready;

   // Write response line
   rand bit [1:0]   m_axil_bresp;
   rand bit         m_axil_bvalid;
        bit         m_axil_bready;

   // Read address line
   
        bit [31:0]  m_axil_araddr;
        bit [2:0]   m_axil_arprot;
        bit         m_axil_arvalid;
   rand bit         m_axil_arready;
   
   // Read data line
   rand bit [31:0]  m_axil_rdata;
   rand bit [1:0]   m_axil_rresp;
   rand bit         m_axil_rvalid;
        bit         m_axil_rready;

 function new (string name="axil_item");
      super.new (name);
   endfunction

   constraint c_operation {
      // m_axil_arready inside {2'b00, 2'b10, 2'b11};
      soft operation == 1'b1;
   } 

   constraint c_num_beats {
      // m_axil_arready inside {2'b00, 2'b10, 2'b11};
      soft num_beats == 7'b0000000;
   } 

   constraint c_m_axil_arready {
      // m_axil_arready inside {2'b00, 2'b10, 2'b11};
      m_axil_arready == 1'b1;
   } 

   constraint c_m_axil_rvalid {
      // m_axil_arready inside {2'b00, 2'b10, 2'b11};
      m_axil_rvalid == 1'b1;
   } 

   constraint c_m_axil_bresp {
      m_axil_bresp inside {2'b00, 2'b10, 2'b11};
      //m_axil_bresp == 2'b00;
   } 

   constraint c_m_axil_rresp {
      m_axil_rresp inside {2'b00, 2'b10, 2'b11};
   }    

   constraint c_m_axil_bvalid {
      m_axil_bvalid inside {[1:1]};
   }

   constraint c_m_axil_awready {
      m_axil_awready inside {[1:1]};
   }     

 // Function to print out the values using $sformatf
   function void print();
      string print_str;
      print_str = $sformatf("AXILite Transaction:\n");
      print_str = {print_str, $sformatf("  Operation: %0d\n", operation)};
      
      // Write address line
      print_str = {print_str, $sformatf("  m_axil_awaddr: 0x%0h\n", m_axil_awaddr)};
      print_str = {print_str, $sformatf("  m_axil_awprot: %0d\n", m_axil_awprot)};
      print_str = {print_str, $sformatf("  m_axil_awvalid: %0d\n", m_axil_awvalid)};
      print_str = {print_str, $sformatf("  m_axil_awready: %0d\n", m_axil_awready)};
      
      // Write data line
      print_str = {print_str, $sformatf("  m_axil_wdata: 0x%0h\n", m_axil_wdata)};
      print_str = {print_str, $sformatf("  m_axil_wstrb: 0x%0h\n", m_axil_wstrb)};
      print_str = {print_str, $sformatf("  m_axil_wvalid: %0d\n", m_axil_wvalid)};
      print_str = {print_str, $sformatf("  m_axil_wready: %0d\n", m_axil_wready)};
      
      // Write response line
      print_str = {print_str, $sformatf("  m_axil_bresp: %0d\n", m_axil_bresp)};
      print_str = {print_str, $sformatf("  m_axil_bvalid: %0d\n", m_axil_bvalid)};
      print_str = {print_str, $sformatf("  m_axil_bready: %0d\n", m_axil_bready)};
      
      // Read address line
      print_str = {print_str, $sformatf("  m_axil_araddr: 0x%0h\n", m_axil_araddr)};
      print_str = {print_str, $sformatf("  m_axil_arprot: %0d\n", m_axil_arprot)};
      print_str = {print_str, $sformatf("  m_axil_arvalid: %0d\n", m_axil_arvalid)};
      print_str = {print_str, $sformatf("  m_axil_arready: %0d\n", m_axil_arready)};
      
      // Read data line
      print_str = {print_str, $sformatf("  m_axil_rdata: 0x%0h\n", m_axil_rdata)};
      print_str = {print_str, $sformatf("  m_axil_rresp: %0d\n", m_axil_rresp)};
      print_str = {print_str, $sformatf("  m_axil_rvalid: %0d\n", m_axil_rvalid)};
      print_str = {print_str, $sformatf("  m_axil_rready: %0d\n", m_axil_rready)};
      
      // Print the formatted string to the console
      $display("%s", print_str);
   endfunction

   function void disp_aw(bit [1:0] sel);
      string aw_chan;
      aw_chan = $sformatf("AXILite Transaction from monitor:\n");
      aw_chan = {aw_chan, $sformatf("  Operation: %0d\n", operation)};
      case(sel)
         2'b00: begin
                  // Write address line
                  aw_chan = {aw_chan, $sformatf("  m_axil_awaddr: 0x%0h\n", m_axil_awaddr)};
                  aw_chan = {aw_chan, $sformatf("  m_axil_awprot: %0d\n", m_axil_awprot)};
                  aw_chan = {aw_chan, $sformatf("  m_axil_awvalid: %0d\n", m_axil_awvalid)};
                  aw_chan = {aw_chan, $sformatf("  m_axil_awready: %0d\n", m_axil_awready)};
                end
         2'b01: begin
                  // Write data line
                  aw_chan = {aw_chan, $sformatf("  m_axil_wdata: 0x%0h\n", m_axil_wdata)};
                  aw_chan = {aw_chan, $sformatf("  m_axil_wstrb: 0x%0h\n", m_axil_wstrb)};
                  aw_chan = {aw_chan, $sformatf("  m_axil_wvalid: %0d\n", m_axil_wvalid)};
                  aw_chan = {aw_chan, $sformatf("  m_axil_wready: %0d\n", m_axil_wready)};
                end
         2'b10: begin
                  // Write response line
                  aw_chan = {aw_chan, $sformatf("  m_axil_bresp: %0d\n", m_axil_bresp)};
                  aw_chan = {aw_chan, $sformatf("  m_axil_bvalid: %0d\n", m_axil_bvalid)};
                  aw_chan = {aw_chan, $sformatf("  m_axil_bready: %0d\n", m_axil_bready)};
                end
         default: aw_chan = {aw_chan, $sformatf("  Do not recognize channel\n")};
      endcase

      // Print the formatted string to the console
      $display("%s", aw_chan);

   endfunction

    virtual function string conv2str(bit [1:0] sel);
        string s;
        case(sel)
         2'b00: begin
                  // Write address line
                  s = {s, $sformatf("  m_axil_awaddr: 0x%0h\n", m_axil_awaddr)};
                  s = {s, $sformatf("  m_axil_awprot: %0d\n", m_axil_awprot)};
                  s = {s, $sformatf("  m_axil_awvalid: %0d\n", m_axil_awvalid)};
                  s = {s, $sformatf("  m_axil_awready: %0d\n", m_axil_awready)};
                end
         2'b01: begin
                  // Write data line
                  s = {s, $sformatf("  m_axil_wdata: 0x%0h\n", m_axil_wdata)};
                  s = {s, $sformatf("  m_axil_wstrb: 0x%b\n", m_axil_wstrb)};
                  s = {s, $sformatf("  m_axil_wvalid: %0d\n", m_axil_wvalid)};
                  s = {s, $sformatf("  m_axil_wready: %0d\n", m_axil_wready)};
                end
         2'b10: begin
                  // Write response line
                  s = {s, $sformatf("  m_axil_bresp: %0d\n", m_axil_bresp)};
                  s = {s, $sformatf("  m_axil_bvalid: %0d\n", m_axil_bvalid)};
                  s = {s, $sformatf("  m_axil_bready: %0d\n", m_axil_bready)};
                end
         default: s = {s, $sformatf("  Do not recognize channel\n")};
      endcase
        return s;
    endfunction

endclass                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                