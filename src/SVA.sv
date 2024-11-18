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

property handshake_valid_pass_through_DUT (bit master, bit slave);
    @(posedge clk)
    disable iff (rst)
    master |-> ##[1:5] (slave == master);
endproperty

property handshake_ready_pass_through_DUT (bit master, bit slave);
    @(posedge clk)
    disable iff (rst)
    slave |-> (slave == !master);
endproperty

property handshake_transaction (bit valid, bit ready);
    @(posedge clk)
    disable iff (rst)
    valid |-> ##[0:3] ready;
endproperty

property b_valid_condition ();
    @(posedge clk)
    disable iff (rst)
    (s_axi_wlast == 1'b1) [*3] |-> ##3 s_axi_bvalid;
endproperty

property success_data_after_handshake (bit valid, bit ready, bit data);
    @(posedge clk)
    disable iff (rst)
    (valid && ready) |-> ##[0:1] data;
endproperty

property success_data_after_addr (bit addr_valid, bit addr_ready, bit data);
    @(posedge clk)
    disable iff (rst)
    (addr_valid && addr_ready) |-> ##[0:1] data;
endproperty

property valid_resp_value (bit resp_value, bit signal);
    @(posedge clk)
    disable iff (rst)
    signal |-> ##[0:3] ((resp_value == 0) || (resp_value == 2) || (resp_value == 3));
endproperty

/*=============== VALID RESP VALUE  ===============*/

valid_r_resp_assert: assert property (
    valid_resp_value(s_axi_rresp, s_axi_rvalid)
);

valid_b_resp_assert: assert property (
    valid_resp_value(s_axi_bresp, s_axi_bvalid)
);
/*====================================================================*/


/*=============== HAVE DATA AFTER RECEIVE ADDRESS ===============*/

// r_data_after_addr_assert: assert property (
//     success_data_after_addr(s_axi_arvalid, s_axi_arready, s_axi_rdata)
// );

w_data_after_addr_assert: assert property (
    success_data_after_addr(s_axi_awvalid, s_axi_awready, s_axi_wdata)
);

/*====================================================================*/


/*=============== HAVE DATA AFTER HANDSHAKING COMPLETE ===============*/

ar_receive_success_assert: assert property (
    success_data_after_handshake(s_axi_arvalid, s_axi_arready, s_axi_araddr)
);

aw_receive_success_assert: assert property (
    success_data_after_handshake(s_axi_awvalid, s_axi_awready, s_axi_awaddr)
);

w_receive_success_assert: assert property (
    success_data_after_handshake(s_axi_wvalid, s_axi_wready, s_axi_wdata)
);

b_receive_success_assert: assert property (
    success_data_after_handshake(s_axi_bvalid, s_axi_bready, s_axi_bresp | 1'b1)
);

r_receive_success_assert: assert property (
    success_data_after_handshake(s_axi_rvalid, s_axi_rready, s_axi_rdata)
);

/*====================================================================*/


/*=============== BVALID GENERATION ===============*/

b_valid_assert: assert property (
    b_valid_condition()
);

/*=================================================*/


/*=============== HANDSHAKING SIGNALS INITIATING TRANSACTIONS ===============*/

ar_assert: assert property (
    handshake_transaction(s_axi_arvalid, s_axi_arready)
);

r_assert: assert property (
    handshake_transaction(s_axi_rvalid, s_axi_rready)
);

aw_assert: assert property (
    handshake_transaction(s_axi_awvalid, s_axi_awready)
);

w_assert: assert property (
    handshake_transaction(s_axi_wvalid, s_axi_wready)
);

b_assert: assert property (
    handshake_transaction(s_axi_bvalid, s_axi_bready)
);

/*===========================================================================*/


/*=============== PASSING HANDSHAKING SIGNALS THROUGH THE DUT SUCCESSFULLY ===============*/

// ARVALID Propagation
r_addr_valid_assert: assert property (
    handshake_valid_pass_through_DUT(s_axi_arvalid, m_axil_arvalid)
);

// // ARREADY Propagation
// r_addr_ready_assert: assert property (
//     handshake_ready_pass_through_DUT(m_axil_arready, s_axi_arvalid)
// );
    
// AWVALID Propagation
w_addr_valid_assert: assert property (
    handshake_valid_pass_through_DUT(s_axi_awvalid, m_axil_awvalid)
);

// // AWREADY Propagation
// w_addr_ready_assert: assert property (
//     handshake_ready_pass_through_DUT(m_axil_awready, s_axi_awvalid)
// );

// WVALID Propagation
w_data_valid_assert: assert property (
    handshake_valid_pass_through_DUT(s_axi_wvalid, m_axil_wvalid)
);

// // WREADY Propagation
// w_data_ready_assert: assert property (
//     handshake_ready_pass_through_DUT(m_axil_wready, s_axi_wvalid)
// );

// BVALID Propagation
b_resp_valid_assert: assert property (
    handshake_valid_pass_through_DUT(m_axil_bvalid, s_axi_bvalid)
);

// // BREADY Propagation
// b_resp_ready_assert: assert property (
//     handshake_ready_pass_through_DUT(s_axi_bready, m_axil_bvalid)
// );

// RVALID Propagation
r_data_valid_assert: assert property (
    handshake_valid_pass_through_DUT(m_axil_rvalid, s_axi_rvalid)
);

// // RREADY Propagation
// r_data_ready_assert: assert property (
//     handshake_ready_pass_through_DUT(s_axi_rready, m_axil_rvalid)
// );

/*========================================================================================*/



// r_addr_valid_assert: assert property (handshake_pass_through_DUT(s_axi_arvalid, m_axil_arvalid));
// r_addr_valid_cover: cover property (handshake_pass_through_DUT(s_axi_arvalid, m_axil_arvalid));

endmodule : SVA