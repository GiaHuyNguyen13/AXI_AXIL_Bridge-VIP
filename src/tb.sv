// `include "uvm_macros.svh"
`include "uvm.sv"
import uvm_pkg::*;

module tb;
  logic clk, rst;

// Clock gen
  initial begin
    clk = 0;
    forever #10 clk = ~clk; 
  end

// Reset gen
  initial begin
    rst = 1'b1;
    #100 rst = 1'b0;
  end

  // Reset gen
  initial begin
    repeat (1000) @(posedge clk);
    $finish();
  end

  initial begin
  $dumpfile("waveform.vcd");  // Specify the dump file name
  $dumpvars(0, tb); // Dump all signals in the design hierarchy under <top_module>
  end

// Interface connect
  axi_interface axi_if (clk, rst);
  axil_interface axil_if (clk, rst);

// Set interface to database and run test
  initial begin
    uvm_config_db#(virtual axi_interface)::set(null, "uvm_test_top", "axi_interface", axi_if);
    uvm_config_db#(virtual axil_interface)::set(null, "uvm_test_top", "axil_interface", axil_if);
    run_test("burst_test");
  end

  // Instantiate DUT
  axi_axil_adapter #(
    .ADDR_WIDTH(32),              
    .AXI_DATA_WIDTH(32),          
    .AXI_STRB_WIDTH(4),           
    .AXI_ID_WIDTH(8),             
    .AXIL_DATA_WIDTH(32),         
    .AXIL_STRB_WIDTH(4),          
    .CONVERT_BURST(1),            
    .CONVERT_NARROW_BURST(0)      
) dut(

    .clk(clk),
    .rst(rst),

    // AXI slave interface
    .s_axi_awid(axi_if.s_axi_awid),
    .s_axi_awaddr(axi_if.s_axi_awaddr),
    .s_axi_awlen(axi_if.s_axi_awlen),
    .s_axi_awsize(axi_if.s_axi_awsize),
    .s_axi_awburst(axi_if.s_axi_awburst),
    .s_axi_awlock(axi_if.s_axi_awlock),
    .s_axi_awcache(axi_if.s_axi_awcache),
    .s_axi_awprot(axi_if.s_axi_awprot),
    .s_axi_awvalid(axi_if.s_axi_awvalid),
    .s_axi_awready(axi_if.s_axi_awready),
    .s_axi_wdata(axi_if.s_axi_wdata),
    .s_axi_wstrb(axi_if.s_axi_wstrb),
    .s_axi_wlast(axi_if.s_axi_wlast),
    .s_axi_wvalid(axi_if.s_axi_wvalid),
    .s_axi_wready(axi_if.s_axi_wready),
    .s_axi_bid(axi_if.s_axi_bid),
    .s_axi_bresp(axi_if.s_axi_bresp),
    .s_axi_bvalid(axi_if.s_axi_bvalid),
    .s_axi_bready(axi_if.s_axi_bready),
    .s_axi_arid(axi_if.s_axi_arid),
    .s_axi_araddr(axi_if.s_axi_araddr),
    .s_axi_arlen(axi_if.s_axi_arlen),
    .s_axi_arsize(axi_if.s_axi_arsize),
    .s_axi_arburst(axi_if.s_axi_arburst),
    .s_axi_arlock(axi_if.s_axi_arlock),
    .s_axi_arcache(axi_if.s_axi_arcache),
    .s_axi_arprot(axi_if.s_axi_arprot),
    .s_axi_arvalid(axi_if.s_axi_arvalid),
    .s_axi_arready(axi_if.s_axi_arready),
    .s_axi_rid(axi_if.s_axi_rid),
    .s_axi_rdata(axi_if.s_axi_rdata),
    .s_axi_rresp(axi_if.s_axi_rresp),
    .s_axi_rlast(axi_if.s_axi_rlast),
    .s_axi_rvalid(axi_if.s_axi_rvalid),
    .s_axi_rready(axi_if.s_axi_rready),

    // AXI Lite master interface
    .m_axil_awaddr(axil_if.m_axil_awaddr),
    .m_axil_awprot(axil_if.m_axil_awprot),
    .m_axil_awvalid(axil_if.m_axil_awvalid),
    .m_axil_awready(axil_if.m_axil_awready),
    .m_axil_wdata(axil_if.m_axil_wdata),
    .m_axil_wstrb(axil_if.m_axil_wstrb),
    .m_axil_wvalid(axil_if.m_axil_wvalid),
    .m_axil_wready(axil_if.m_axil_wready),
    .m_axil_bresp(axil_if.m_axil_bresp),
    .m_axil_bvalid(axil_if.m_axil_bvalid),
    .m_axil_bready(axil_if.m_axil_bready),
    .m_axil_araddr(axil_if.m_axil_araddr),
    .m_axil_arprot(axil_if.m_axil_arprot),
    .m_axil_arvalid(axil_if.m_axil_arvalid),
    .m_axil_arready(axil_if.m_axil_arready),
    .m_axil_rdata(axil_if.m_axil_rdata),
    .m_axil_rresp(axil_if.m_axil_rresp),
    .m_axil_rvalid(axil_if.m_axil_rvalid),
    .m_axil_rready(axil_if.m_axil_rready)
  );

  // Binding the SVA to the DUT
  bind tb.dut SVA #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_STRB_WIDTH(AXI_DATA_WIDTH/8),
    .AXI_ID_WIDTH(AXI_ID_WIDTH),
    .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
    .AXIL_STRB_WIDTH(AXIL_DATA_WIDTH/8)
) sva_inst (
    .clk(clk),
    .rst(rst),

    // Connect AXI slave interface signals
    .s_axi_awid(s_axi_awid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awlen(s_axi_awlen),
    .s_axi_awsize(s_axi_awsize),
    .s_axi_awburst(s_axi_awburst),
    .s_axi_awlock(s_axi_awlock),
    .s_axi_awcache(s_axi_awcache),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wlast(s_axi_wlast),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bid(s_axi_bid),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_arid(s_axi_arid),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arlen(s_axi_arlen),
    .s_axi_arsize(s_axi_arsize),
    .s_axi_arburst(s_axi_arburst),
    .s_axi_arlock(s_axi_arlock),
    .s_axi_arcache(s_axi_arcache),
    .s_axi_arprot(s_axi_arprot),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rid(s_axi_rid),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rlast(s_axi_rlast),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),

    // Connect AXI lite master interface signals
    .m_axil_awaddr(m_axil_awaddr),
    .m_axil_awprot(m_axil_awprot),
    .m_axil_awvalid(m_axil_awvalid),
    .m_axil_awready(m_axil_awready),
    .m_axil_wdata(m_axil_wdata),
    .m_axil_wstrb(m_axil_wstrb),
    .m_axil_wvalid(m_axil_wvalid),
    .m_axil_wready(m_axil_wready),
    .m_axil_bresp(m_axil_bresp),
    .m_axil_bvalid(m_axil_bvalid),
    .m_axil_bready(m_axil_bready),
    .m_axil_araddr(m_axil_araddr),
    .m_axil_arprot(m_axil_arprot),
    .m_axil_arvalid(m_axil_arvalid),
    .m_axil_arready(m_axil_arready),
    .m_axil_rdata(m_axil_rdata),
    .m_axil_rresp(m_axil_rresp),
    .m_axil_rvalid(m_axil_rvalid),
    .m_axil_rready(m_axil_rready)
    );


endmodule
