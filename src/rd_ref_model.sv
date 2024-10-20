class axi_axil_adapter_rd_ref_model;

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

  // Function to handle an AXI read request
  function void axi_read_request(input axi_item axi_tx);
    // AXI burst length, burst size, and starting address from the AXI transaction
    this.axi_burst_len = axi_tx.s_axi_arlen;  // AXI burst length
    this.axi_burst_size = axi_tx.s_axi_arsize;  // AXI burst size
    this.axi_addr = axi_tx.s_axi_araddr;  // Starting address
  endfunction

  // Function to convert AXI transaction to AXI-Lite transaction
  function axil_item convert_axi_to_axil();
    axil_item axil_tx = axil_item::type_id::create("axil_tx");  // Create an AXI-Lite item

    // Single AXI-Lite read transaction for the current AXI address
    axil_tx.m_axil_araddr = this.axi_addr;  // Pass the address to AXI-Lite

    // Fetch data from the centralized memory model
    axil_tx.m_axil_rdata = this.mem.read(this.axi_addr);  // Use the centralized memory for read data

    // Increment the AXI address for the next burst transfer
    this.axi_addr = this.axi_addr + (1 << this.axi_burst_size);  
    this.axi_burst_len--;

    // Set other fields for the AXI-Lite transaction
    axil_tx.m_axil_arprot = 3'b000;  // Assuming no special protection bits
    axil_tx.m_axil_arvalid = 1'b1;   // Valid read request
    axil_tx.m_axil_rvalid = 1'b1;    // Valid read response
    axil_tx.m_axil_rresp = 2'b00;    // OKAY response

    return axil_tx;
  endfunction

  // Task to convert an entire AXI burst into AXI-Lite transactions
  function void convert_burst_to_axil(output axil_item axil_tx[]);
    int idx = 0;
    axil_tx = new[this.axi_burst_len];  // Initialize the array for AXI-Lite items
    while (this.axi_burst_len > 0) begin
      axil_tx[idx] = convert_axi_to_axil();  // Convert each part of the burst to AXI-Lite
      idx++;
    end
  endfunction

endclass
