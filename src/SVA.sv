module SVA #(
    // Use the same parameters as DUT for consistent interface sizing
    parameter ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8),
    parameter AXI_ID_WIDTH = 8,
    parameter AXIL_DATA_WIDTH = 32,
    parameter AXIL_STRB_WIDTH = (AXIL_DATA_WIDTH/8)
)(
    input  wire                        clk,
    input  wire                        rst,

    // AXI slave interface (inputs to DUT, monitoring their behavior)
    input  wire [AXI_ID_WIDTH-1:0]     s_axi_awid,
    input  wire [ADDR_WIDTH-1:0]       s_axi_awaddr,
    input  wire [7:0]                  s_axi_awlen,
    input  wire [2:0]                  s_axi_awsize,
    input  wire [1:0]                  s_axi_awburst,
    input  wire                        s_axi_awlock,
    input  wire [3:0]                  s_axi_awcache,
    input  wire [2:0]                  s_axi_awprot,
    input  wire                        s_axi_awvalid,
    input  wire                        s_axi_wlast,
    input  wire [AXI_DATA_WIDTH-1:0]   s_axi_wdata,
    input  wire [AXI_STRB_WIDTH-1:0]   s_axi_wstrb,
    input  wire                        s_axi_wvalid,
    input  wire [AXI_ID_WIDTH-1:0]     s_axi_arid,
    input  wire [ADDR_WIDTH-1:0]       s_axi_araddr,
    input  wire [7:0]                  s_axi_arlen,
    input  wire [2:0]                  s_axi_arsize,
    input  wire [1:0]                  s_axi_arburst,
    input  wire                        s_axi_arlock,
    input  wire [3:0]                  s_axi_arcache,
    input  wire [2:0]                  s_axi_arprot,
    input  wire                        s_axi_arvalid,
    input  wire                        s_axi_rready,
    input  wire                        s_axi_bready,

    // AXI slave interface (outputs from DUT, checking for proper behavior)
    input  wire                        s_axi_awready,
    input  wire                        s_axi_wready,
    input  wire [AXI_ID_WIDTH-1:0]     s_axi_bid,
    input  wire [1:0]                  s_axi_bresp,
    input  wire                        s_axi_bvalid,
    input  wire                        s_axi_arready,
    input  wire [AXI_ID_WIDTH-1:0]     s_axi_rid,
    input  wire [AXI_DATA_WIDTH-1:0]   s_axi_rdata,
    input  wire [1:0]                  s_axi_rresp,
    input  wire                        s_axi_rlast,
    input  wire                        s_axi_rvalid,

    // AXI lite master interface (outputs from DUT, checking for correct behavior)
    input  wire [ADDR_WIDTH-1:0]       m_axil_awaddr,
    input  wire [2:0]                  m_axil_awprot,
    input  wire                        m_axil_awvalid,
    input  wire [AXIL_DATA_WIDTH-1:0]  m_axil_wdata,
    input  wire [AXIL_STRB_WIDTH-1:0]  m_axil_wstrb,
    input  wire                        m_axil_wvalid,
    input  wire                        m_axil_bready,
    input  wire [ADDR_WIDTH-1:0]       m_axil_araddr,
    input  wire [2:0]                  m_axil_arprot,
    input  wire                        m_axil_arvalid,
    input  wire                        m_axil_rready,

    // AXI lite master interface (inputs to DUT, monitoring signals)
    input  wire                        m_axil_awready,
    input  wire                        m_axil_wready,
    input  wire [1:0]                  m_axil_bresp,
    input  wire                        m_axil_bvalid,
    input  wire                        m_axil_arready,
    input  wire [AXIL_DATA_WIDTH-1:0]  m_axil_rdata,
    input  wire [1:0]                  m_axil_rresp,
    input  wire                        m_axil_rvalid
);

property handshake_pass_through_DUT (bit master, bit slave);
    @(posedge clk)
    disable iff (rst)
    master |-> ##[1:5] slave;
endproperty

r_addr_valid_assert: assert property (handshake_pass_through_DUT(s_axi_arvalid, m_axil_arvalid)) else $display("ehre");
// r_addr_valid_cover: cover property (handshake_pass_through_DUT(s_axi_arvalid, m_axil_arvalid));

endmodule : SVA