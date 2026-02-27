module tage_top #(
    parameter HIST_LEN = 64,
    parameter N_TABLES = 3
)(
    input  logic         clk,
    input  logic         rst,
    input  logic [31:0]  pc_i,
    input  logic         br_resolved_i,
    input  logic         br_taken_i,     // EX stage actual outcome
    input  logic         update_i,       // EX stage enable update

    output logic         pred_o
);

    // ----------------------------
    // 1. GHR
    // ----------------------------
    logic [HIST_LEN-1:0] ghr_out;
    ghr #(.HIST(HIST_LEN)) gh (
        .clk(clk),
        .rst(rst),
        .update_i(update_i),
        .taken_i(br_taken_i),
        .history_o(ghr_out)
    );

    // ----------------------------
    // 2. Base predictor (BHT)
    // ----------------------------
    logic base_pred;
    bht base_bht (
        .clk_i(clk),
        .br_result_i(br_taken_i),
        .update_en_i(update_i),
        .idx_i(pc_i[10:0]),  // simple 2^11 entry
        .prediction_o(base_pred)
    );

    // ----------------------------
    // 3. Tagged tables
    // ----------------------------
    logic [2:0] tag_hits;
    logic [2:0] table_preds;
    logic [2:0] allocs;
    
    // simple array of tables
    logic [8:0] tags [N_TABLES-1:0];
    logic [2:0] ctrs [N_TABLES-1:0];

    genvar i;
    generate
        for (i = 0; i < N_TABLES; i=i+1) begin : tage_tables
            // Compute index
            logic [8:0] idx = pc_i[8:0] ^ ghr_out[i*10 +: 9]; 
            // Compute tag (simplified)
            logic [8:0] tag = pc_i[8:0] ^ ghr_out[i*10 +: 9];

            // Check tag hit
            assign tag_hits[i] = (tags[i] == tag);
            // Prediction from table
            assign table_preds[i] = ctrs[i][2]; // MSB is prediction

            // Update logic
            always_ff @(posedge clk) begin
                if (rst) begin
                    tags[i] <= '0;
                    ctrs[i] <= 3'b100; // weakly taken
                end
                else if (update_i && tag_hits[i]) begin
                    // update counter
                    if (br_taken_i && ctrs[i] != 3'b111)
                        ctrs[i] <= ctrs[i] + 1;
                    else if (!br_taken_i && ctrs[i] != 3'b000)
                        ctrs[i] <= ctrs[i] - 1;
                end
                else if (update_i && !tag_hits[i] && allocs[i]) begin
                    // allocate new entry
                    tags[i] <= tag;
                    ctrs[i] <= 3'b100; // weakly taken
                end
            end
        end
    endgenerate

    // ----------------------------
    // 4. Choose prediction
    // ----------------------------
    // pick longest matching table
    logic found;
    always_comb begin
        pred_o = base_pred;
        found = 0;
        for (int j = N_TABLES-1; j >= 0; j=j-1) begin
            if (tag_hits[j] && !found) begin
                pred_o = table_preds[j];
                found = 1;
            end
        end
    end

endmodule
