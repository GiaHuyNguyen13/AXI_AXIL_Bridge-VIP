class axil_item extends uvm_sequence_item;
    `uvm_object_utils(axil_item)

   rand bit         operation; // 0 for read, 1 for write

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
      operation == 1'b0;
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
      m_axil_rresp inside {2'b00, 2'b10, 2'b11};
   } 

   constraint c_m_axil_rresp {
      m_axil_rresp inside {2'b00, 2'b10, 2'b11};
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

endclass                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                