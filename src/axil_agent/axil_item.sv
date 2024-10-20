class axil_item extends uvm_sequence_item;
    `uvm_object_utils(axil_item)
   function new (string name="axil_item", uvm_component parent);
      super.new (name, parent);
   endfunction

   // rand bit         operation; // 0 for read, 1 for write

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

   
   constraint c_m_axil_bresp {
      m_axil_rresp inside {2'b00, 2'b10, 2'b11};
   } 

   constraint c_m_axil_rresp {
      m_axil_rresp inside {2'b00, 2'b10, 2'b11};
   }    

endclass                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                