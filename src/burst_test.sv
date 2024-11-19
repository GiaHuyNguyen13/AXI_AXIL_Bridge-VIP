class burst_test extends base_test;
  `uvm_component_utils(burst_test)
  function new(string name="burst_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  bit operation = 1; // 0  for read, 1 for write
  bit [31:0] test_num = 100;
  bit [7:0] burst_len = 2; // 0 is 1 beat, 1 is 2 beat, ...
  bit [13:0] axil_num = test_num * (burst_len + 1);
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(bit[7:0])::set(this, "*", "burst_len", burst_len);

    axi_seq.randomize() with { 
        num == test_num;
        op == operation;
        len == burst_len;
    };

    axil_seq.randomize() with { 
        num == axil_num;
        op == operation;
        len == burst_len;
    };
    
  endfunction
endclass