class axi_axil_adapter_wr_ref_model;

  // Handle for the centralized memory model
  centralized_memory_model mem;

  // Internal state variables to track burst processing
  int axi_burst_len;
  int axi_burst_size;
  logic [31:0] axi_addr;  // Assuming 32-bit addresses

  // Constructor
  function new();
    // Initialize internal states
    this.axi_burst_len = 0;
    this.axi_burst_size = 0;
    this.axi_addr = 0;
  endfunction

  // Function to set the centralized memory model
  function void set_memory(centralized_memory_model memory);
    this.mem = memory;  // Store the reference to the centralized memory
  endfunction

  // Function to handle an AXI write request
  function void axi_write_request(input axi_item axi_tx);
    // AXI burst length, burst size, and starting address from the AXI transaction
    this.axi_burst_len = axi_tx.s_axi_awlen;    // AXI burst length for write
    this.axi_burst_size = axi_tx.s_axi_awsize;  // AXI burst size for write
    this.axi_addr = axi_tx.s_axi_awaddr;        // Starting address for write
  endfunction

  // Function to convert AXI write transaction to AXI-Lite transaction
  function axil_item convert_axi_to_axil_write();
    axil_item axil_tx = axil_item::type_id::create("axil_tx_write");  // Create an AXI-Lite write item

    // Set the write address for the AXI-Lite transaction
    axil_tx.m_axil_awaddr = this.axi_addr;      // Address for AXI-Lite write

    // Fetch data from the centralized memory model to be written to the bridge
    axil_tx.m_axil_wdata = this.mem.read(this.axi_addr);  // Read data from memory to be written

    // Increment the AXI address for the next burst transfer
    this.axi_addr = this.axi_addr + (1 << this.axi_burst_size);
    this.axi_burst_len--;

    // Set other fields for the AXI-Lite write transaction
    axil_tx.m_axil_awprot = 3'b000;  // Assuming no special protection bits
    axil_tx.m_axil_awvalid = 1'b1;   // Valid write request
    axil_tx.m_axil_wvalid = 1'b1;    // Valid write data
    axil_tx.m_axil_bvalid = 1'b1;    // Valid write response
    axil_tx.m_axil_bresp = 2'b00;    // OKAY response

    return axil_tx;
  endfunction

  // Task to convert an entire AXI write burst into AXI-Lite transactions
  function void convert_burst_to_axil_write(output axil_item axil_tx[]);
    int idx = 0;
    axil_tx = new[this.axi_burst_len];  // Initialize the array for AXI-Lite items
    while (this.axi_burst_len > 0) begin
      axil_tx[idx] = convert_axi_to_axil_write();  // Convert each part of the burst to AXI-Lite write
      idx++;
    end
  endfunction

endclass
