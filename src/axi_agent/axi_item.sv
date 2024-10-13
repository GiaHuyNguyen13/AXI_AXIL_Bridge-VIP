class item extends uvm_sequence_item;
    `uvm_object_utils(item)
   function new (string name="item", uvm_component parent);
      super.new (name, parent);
   endfunction

   rand bit [1:0] input_1;
   rand bit [7:0] input_2;
   bit[31:0] output_1;

endclass                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                