module question4;
int arr[] = '{8,3,3,4,5,6,3,5,4,6,8,7,6,4,3,5,6};
int freq[int];
initial begin
    foreach(arr[i]) begin
        freq[arr[i]]++;
    end
    foreach(freq[i]) begin
        $display("%d -> %d times",i,freq[i]);
    end
end
endmodule