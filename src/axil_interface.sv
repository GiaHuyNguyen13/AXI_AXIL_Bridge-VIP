interface axil_interface #
(
    parameter ADDR_WIDTH = 32,
    parameter AXIL_DATA_WIDTH = 32,
    parameter AXIL_STRB_WIDTH = (AXIL_DATA_WIDTH / 8)
)
(
    input  logic clk,
    input  logic rst
);
    // AXI Lite master write address channel
    logic [ADDR_WIDTH-1:0]       m_axil_awaddr;
    logic [2:0]                  m_axil_awprot;
    logic                        m_axil_awvalid;
    logic                        m_axil_awready;

    // AXI Lite master write data channel
    logic [AXIL_DATA_WIDTH-1:0]  m_axil_wdata;
    logic [AXIL_STRB_WIDTH-1:0]  m_axil_wstrb;
    logic                        m_axil_wvalid;
    logic                        m_axil_wready;

    // AXI Lite master write response channel
    logic [1:0]                  m_axil_bresp;
    logic                        m_axil_bvalid;
    logic                        m_axil_bready;

    // AXI Lite master read address channel
    logic [ADDR_WIDTH-1:0]       m_axil_araddr;
    logic [2:0]                  m_axil_arprot;
    logic                        m_axil_arvalid;
    logic                        m_axil_arready;

    // AXI Lite master read data channel
    logic [AXIL_DATA_WIDTH-1:0]  m_axil_rdata;
    logic [1:0]                  m_axil_rresp;
    logic                        m_axil_rvalid;
    logic                        m_axil_rready;

endinterface