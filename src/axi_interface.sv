interface axi_interface #
(
    parameter ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8),
    parameter AXI_ID_WIDTH = 8,
    parameter AXIL_DATA_WIDTH = 32,
    parameter AXIL_STRB_WIDTH = (AXIL_DATA_WIDTH/8),
    parameter CONVERT_BURST = 1,
    parameter CONVERT_NARROW_BURST = 0
)
(
    input  logic clk,
    input  logic rst
);

    // AXI slave interface
    logic [AXI_ID_WIDTH-1:0]    s_axi_awid;
    logic [ADDR_WIDTH-1:0]      s_axi_awaddr;
    logic [7:0]                 s_axi_awlen;
    logic [2:0]                 s_axi_awsize;
    logic [1:0]                 s_axi_awburst;
    logic                       s_axi_awlock;
    logic [3:0]                 s_axi_awcache;
    logic [2:0]                 s_axi_awprot;
    logic                       s_axi_awvalid;
    logic                       s_axi_awready;
    logic [AXI_DATA_WIDTH-1:0]  s_axi_wdata;
    logic [AXI_STRB_WIDTH-1:0]  s_axi_wstrb;
    logic                       s_axi_wlast;
    logic                       s_axi_wvalid;
    logic                       s_axi_wready;
    logic [AXI_ID_WIDTH-1:0]    s_axi_bid;
    logic [1:0]                 s_axi_bresp;
    logic                       s_axi_bvalid;
    logic                       s_axi_bready;
    logic [AXI_ID_WIDTH-1:0]    s_axi_arid;
    logic [ADDR_WIDTH-1:0]      s_axi_araddr;
    logic [7:0]                 s_axi_arlen;
    logic [2:0]                 s_axi_arsize;
    logic [1:0]                 s_axi_arburst;
    logic                       s_axi_arlock;
    logic [3:0]                 s_axi_arcache;
    logic [2:0]                 s_axi_arprot;
    logic                       s_axi_arvalid;
    logic                       s_axi_arready;
    logic [AXI_ID_WIDTH-1:0]    s_axi_rid;
    logic [AXI_DATA_WIDTH-1:0]  s_axi_rdata;
    logic [1:0]                 s_axi_rresp;
    logic                       s_axi_rlast;
    logic                       s_axi_rvalid;
    logic                       s_axi_rready;

endinterface