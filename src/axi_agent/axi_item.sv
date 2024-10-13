class axi_item extends uvm_sequence_item;
    `uvm_object_utils(axi_item)

   rand bit    operation; // 0 for read, 1 for write

   // Write address line
   rand bit [7:0]   s_axi_awid;
   rand bit [31:0]  s_axi_awaddr;
   rand bit [7:0]   s_axi_awlen;
   rand bit [2:0]   s_axi_awsize;
   rand bit [1:0]   s_axi_awburst;
   rand bit         s_axi_awlock;
   rand bit [3:0]   s_axi_awcache;
   rand bit [2:0]   s_axi_awprot;
   rand bit         s_axi_awvalid;
        bit         s_axi_awready;

   // Write data line
   rand bit [31:0]  s_axi_wdata;
   rand bit [3:0]   s_axi_wstrb;
   rand bit         s_axi_wlast;
   rand bit         s_axi_wvalid;
        bit         s_axi_wready;

   // Write response line
        bit [7:0]   s_axi_bid;
        bit [1:0]   s_axi_bresp;
        bit         s_axi_bvalid;
   rand bit         s_axi_bready;

   // Read address line
   rand bit [7:0]   s_axi_arid;
   rand bit [31:0]  s_axi_araddr;
   rand bit [7:0]   s_axi_arlen;
   rand bit [2:0]   s_axi_arsize;
   rand bit [1:0]   s_axi_arburst;
   rand bit         s_axi_arlock;
   rand bit [3:0]   s_axi_arcache;
   rand bit [2:0]   s_axi_arprot;
   rand bit         s_axi_arvalid;
        bit         s_axi_arready;
   
   // Read data line
        bit [7:0]   s_axi_rid;
        bit [31:0]  s_axi_rdata;
        bit [1:0]   s_axi_rresp;
        bit         s_axi_rlast;
        bit         s_axi_rvalid;
   rand bit         s_axi_rready;


   function new (string name="axi_item");
      super.new (name);
   endfunction

   // *********** CONSTRAINTS *********** //

   constraint c_s_axi_awid {
      s_axi_awid inside {[0:255]};
   }

   constraint c_s_axi_awaddr {
      s_axi_awaddr inside {[0:2**32-1]};
   }

   constraint c_s_axi_awlen {
      s_axi_awlen inside {[0:255]};
   }

   constraint c_s_axi_awsize {
      s_axi_awsize inside {[0:7]};
   }

   constraint c_s_axi_awburst {
      s_axi_awburst inside {[0:3]};
   }

   constraint c_s_axi_awlock {
      s_axi_awlock inside {[0:1]};
   }

   constraint c_s_axi_awvalid {
      s_axi_awvalid inside {[0:1]};
   }

   constraint c_s_axi_wdata {
      s_axi_wdata inside {[0:2**32-1]};
   }

   constraint c_s_axi_wstrb {
      s_axi_wstrb inside {[0:15]};
   }

   constraint c_s_axi_wlast {
      s_axi_wlast inside {[0:1]};
   }

   constraint c_s_axi_wvalid {
      s_axi_wvalid inside {[0:1]};
   }

   constraint c_s_axi_bready {
      s_axi_bready inside {[0:1]};
   }

   constraint c_s_axi_arid {
      s_axi_arid inside {[0:255]};
   }

   constraint c_s_axi_araddr {
      s_axi_araddr inside {[0:2**32-1]};
   }

   constraint c_s_axi_arlen {
      s_axi_arlen inside {[0:255]};
   }

   constraint c_s_axi_arsize {
      s_axi_arsize inside {[0:7]};
   }

   constraint c_s_axi_arburst {
      s_axi_arburst inside {[0:3]};
   }

   constraint c_s_axi_arlock {
      s_axi_arlock inside {[0:1]};
   }

   constraint c_s_axi_arvalid {
      s_axi_arvalid inside {[0:1]};
   }

   constraint c_s_axi_rready {
      s_axi_rready inside {[0:1]};
   }

   constraint prot_cache_zero {
      s_axi_arprot == 3'b000;
      s_axi_awprot == 3'b000;
      s_axi_arcache == 4'b0000;
      s_axi_awcache == 4'b0000;
   }

endclass                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                