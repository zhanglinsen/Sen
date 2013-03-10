package apparat.lzma {
	/**
	 * @author Joa Ebert
	 */
	internal final class LenDecoder {
		private var _choice: Array = new Array(2)
		private var _lowCoder: Array = new Array(Base.kNumPosStatesMax)
		private var _midCoder: Array = new Array(Base.kNumPosStatesMax)
		private var _highCoder: BitTreeDecoder = new BitTreeDecoder(Base.kNumHighLenBits)
		private var _numPosStates: int = 0;

		public function create(numPosStates: int): void {
			for(; _numPosStates < numPosStates; ++_numPosStates) {
				_lowCoder[_numPosStates] = new BitTreeDecoder(Base.kNumLowLenBits)
				_midCoder[_numPosStates] = new BitTreeDecoder(Base.kNumMidLenBits)
			}
		}

		public function init(): void {
			Decoder.initBitModels(_choice)

			for(var posState: int = 0; posState < _numPosStates; ++posState) {
				_lowCoder[posState].init()
				_midCoder[posState].init()
			}

			_highCoder.init()
		}


		public function decode(rangeDecoder: Decoder, posState: int): int {
			if(rangeDecoder.decodeBit(_choice, 0) == 0) {
				return _lowCoder[posState].decode(rangeDecoder)
			}

			var symbol: int = Base.kNumLowLenSymbols

			if(rangeDecoder.decodeBit(_choice, 1) == 0) {
				symbol += _midCoder[posState].decode(rangeDecoder)
			} else {
				symbol += Base.kNumMidLenSymbols + _highCoder.decode(rangeDecoder)
			}

			return symbol
		}
	}
}