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
   constraint c_op {
      soft operation == 1;
    }
   constraint c_s_axi_awid {
      s_axi_awid inside {[0:255]};
   }

   constraint c_s_axi_awaddr {
      s_axi_awaddr inside {[0:15]};
   }

   constraint c_s_axi_awlen {
      soft s_axi_awlen inside {[3:3]};
   }

   constraint c_s_axi_awsize {
      s_axi_awsize inside {[0:0]};
   }

   constraint c_s_axi_awburst {
      s_axi_awburst inside {[0:0]};
   }

   constraint c_s_axi_awlock {
      s_axi_awlock inside {[0:0]};
   }

   constraint c_s_axi_awvalid {
      s_axi_awvalid inside {[1:1]};
   }

   constraint c_s_axi_wdata {
      s_axi_wdata inside {[0:2**32-1]};
   }

   constraint c_s_axi_wstrb {
      s_axi_wstrb inside {[0:15]};
   }

   constraint c_s_axi_wlast {
      s_axi_wlast inside {[1:1]};
   }

   constraint c_s_axi_wvalid {
      s_axi_wvalid inside {[1:1]};
   }

   constraint c_s_axi_bready {
      s_axi_bready inside {[1:1]};
   }

   constraint c_s_axi_arid {
      // s_axi_arid inside {[0:255]};
      s_axi_arid == 1;
   }

   constraint c_s_axi_araddr {
      s_axi_araddr inside {[1:10]};
      // s_axi_araddr == 1;
   }

   constraint c_s_axi_arlen {
      // s_axi_arlen inside {[0:255]};
      soft s_axi_arlen == 1;
   }

   constraint c_s_axi_arsize {
      // s_axi_arsize inside {[0:7]};
      s_axi_arsize == 1;
   }

   constraint c_s_axi_arburst {
      // s_axi_arburst inside {[0:3]};
      s_axi_arburst == 0;
   }

   constraint c_s_axi_arlock {
      s_axi_arlock inside {[0:0]};
   }

   constraint c_s_axi_arvalid {
      // s_axi_arvalid inside {[0:1]};
      s_axi_arvalid == 1'b1;
   }

   constraint c_s_axi_rready {
      s_axi_rready inside {[1:1]};
   }

   constraint prot_cache_zero {
      s_axi_arprot == 3'b000;
      s_axi_awprot == 3'b000;
      s_axi_arcache == 4'b0000;
      s_axi_awcache == 4'b0000;
   }

function void print();
      string print_str;
      print_str = $sformatf("AXI Transaction:\n");
      print_str = {print_str, $sformatf("  Operation: %0d\n", operation)};
      
      // Write address line
      print_str = {print_str, $sformatf("  s_axi_awid: 0x%0h\n", s_axi_awid)};
      print_str = {print_str, $sformatf("  s_axi_awaddr: 0x%0h\n", s_axi_awaddr)};
      print_str = {print_str, $sformatf("  s_axi_awlen: %0d\n", s_axi_awlen)};
      print_str = {print_str, $sformatf("  s_axi_awsize: %0d\n", s_axi_awsize)};
      print_str = {print_str, $sformatf("  s_axi_awburst: %0d\n", s_axi_awburst)};
      print_str = {print_str, $sformatf("  s_axi_awlock: %0d\n", s_axi_awlock)};
      print_str = {print_str, $sformatf("  s_axi_awcache: 0x%0h\n", s_axi_awcache)};
      print_str = {print_str, $sformatf("  s_axi_awprot: %0d\n", s_axi_awprot)};
      print_str = {print_str, $sformatf("  s_axi_awvalid: %0d\n", s_axi_awvalid)};
      print_str = {print_str, $sformatf("  s_axi_awready: %0d\n", s_axi_awready)};
      
      // Write data line
      print_str = {print_str, $sformatf("  s_axi_wdata: 0x%0h\n", s_axi_wdata)};
      print_str = {print_str, $sformatf("  s_axi_wstrb: 0x%0h\n", s_axi_wstrb)};
      print_str = {print_str, $sformatf("  s_axi_wlast: %0d\n", s_axi_wlast)};
      print_str = {print_str, $sformatf("  s_axi_wvalid: %0d\n", s_axi_wvalid)};
      print_str = {print_str, $sformatf("  s_axi_wready: %0d\n", s_axi_wready)};
      
      // Write response line
      print_str = {print_str, $sformatf("  s_axi_bid: 0x%0h\n", s_axi_bid)};
      print_str = {print_str, $sformatf("  s_axi_bresp: %0d\n", s_axi_bresp)};
      print_str = {print_str, $sformatf("  s_axi_bvalid: %0d\n", s_axi_bvalid)};
      print_str = {print_str, $sformatf("  s_axi_bready: %0d\n", s_axi_bready)};
      
      // Read address line
      print_str = {print_str, $sformatf("  s_axi_arid: 0x%0h\n", s_axi_arid)};
      print_str = {print_str, $sformatf("  s_axi_araddr: 0x%0h\n", s_axi_araddr)};
      print_str = {print_str, $sformatf("  s_axi_arlen: %0d\n", s_axi_arlen)};
      print_str = {print_str, $sformatf("  s_axi_arsize: %0d\n", s_axi_arsize)};
      print_str = {print_str, $sformatf("  s_axi_arburst: %0d\n", s_axi_arburst)};
      print_str = {print_str, $sformatf("  s_axi_arlock: %0d\n", s_axi_arlock)};
      print_str = {print_str, $sformatf("  s_axi_arcache: 0x%0h\n", s_axi_arcache)};
      print_str = {print_str, $sformatf("  s_axi_arprot: %0d\n", s_axi_arprot)};
      print_str = {print_str, $sformatf("  s_axi_arvalid: %0d\n", s_axi_arvalid)};
      print_str = {print_str, $sformatf("  s_axi_arready: %0d\n", s_axi_arready)};
      
      // Read data line
      print_str = {print_str, $sformatf("  s_axi_rid: 0x%0h\n", s_axi_rid)};
      print_str = {print_str, $sformatf("  s_axi_rdata: 0x%0h\n", s_axi_rdata)};
      print_str = {print_str, $sformatf("  s_axi_rresp: %0d\n", s_axi_rresp)};
      print_str = {print_str, $sformatf("  s_axi_rlast: %0d\n", s_axi_rlast)};
      print_str = {print_str, $sformatf("  s_axi_rvalid: %0d\n", s_axi_rvalid)};
      print_str = {print_str, $sformatf("  s_axi_rready: %0d\n", s_axi_rready)};
      
      // Print the formatted string to the console
      $display("%s", print_str);
   endfunction
endclass                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                