module question3;
int arr[] = '{45,34,67,89,78};
int max=0;
int second=0;
initial begin
     foreach(arr[i]) begin
        if (arr[i] > max) begin
            second = max;
            max = arr[i];
        end
        else if ((arr[i]>second) && (arr[i]!=max))  second = arr[i];
    end
        $display("second to max = %d",second);
end
endmodule