


interface IExchange{
    public swap(
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 poolFee
    ) external returns(bool _success);
}