import Foundation


class LogicPhrase : LogicValue {
	static let SIZE_INCREMENT:UInt32 = 100


//Fields
	private var words:[LogicWord?]
	private var length:UInt32


//Constructors
	init(num:Int = 10) {
		words = [LogicWord?](repeating: nil, count:num)
		length = 0
	}

	convenience init(words:[LogicWord?], plus:Int = 0) {
		self.init(num: words.count + plus)
		self.copy(words: words)
	}


//Getters
	public func getLength() -> UInt32 { return length }
	public func getCapacity() -> UInt32 { return UInt32(words.count) }
	public func getWords() -> [LogicWord?] { return words }


//Space management
	public func ensureCapacity(_ capacity:UInt32) {
		words.reserveCapacity(Int(capacity))
		for _ in words.count..<words.capacity {words.append(nil)}
	}

	public func saveSpace() {
		let slice: ArraySlice<LogicWord?> = words[0 ..< Int(length)]
		words = Array(slice)
	}


//Logic Word Manipulation
	public func add(_ word: LogicWord) {
		if Int(length) >= words.count {
			ensureCapacity(length + LogicPhrase.SIZE_INCREMENT)
		}

		words[Int(length)] = word
		length += 1
	}



//Cloning
	public func copy(from:LogicPhrase, plus:Int = 0) {
		words = [LogicWord?](repeating: nil, count:from.words.count + plus)
		for i in 0..<from.getLength() { print(i) ; words[Int(i)] = from.words[Int(i)] }

		length = UInt32(from.words.count)
	}
	public func copy(words: [LogicWord?]) {
		self.words.removeAll()
		self.words.reserveCapacity(words.count)
		for i in 0..<words.count { self.words.append(words[i]) }

		self.length = UInt32(words.count)
	}


//matching
	public func match(_ phrs:LogicPhrase, pos:UInt32) -> Bool {
		let srchLen:UInt32 = phrs.length
		if pos+srchLen>length {return false}

		let words2: [LogicWord?] = phrs.words;
		var p:Int = Int(pos)
		for i in 0..<Int(srchLen) {
			if words[p] !== words2[i] {return false}
			p += 1
		}

		return true
	}

	public func select(_ target:LogicPhrase, sel:inout [UInt32]) {
		let words2:[LogicWord?] = target.words
		let phrsLen:UInt32 = target.length
		let first:LogicWord = words2[0]!
		var srchIndex:Int=0,
			srchTester:Int=0,
			srcLimit:Int=Int(length)-Int(phrsLen)

		sel.removeAll()
		A: while(true) {
			B: while(true) {					//1. search for first symbol
				if srchIndex>srcLimit {break A}
				if words[srchIndex] === first {break B}	//symbol found!
				srchIndex+=1
			}

			srchTester = srchIndex+1
			for index in 1..<Int(phrsLen) {			//2. check other symbols
				if words[srchTester] !== words2[index] {
					srchTester+=1
					srchIndex+=1
					continue A  //if failed to match, move the pointer one step and start again.
				}
				else { srchTester+=1 }
			}

			sel.append(UInt32(srchIndex))
			srchIndex = srchTester //move the pointer to the next search point
		}
	}


//replacing
	private class func moveInternally(_ wrd: inout [LogicWord?], src:UInt32, targ:UInt32, len:UInt32) {
		var lenV = len
		var targV = Int(targ)
		var srcV = Int(src)
		while lenV>0 {
			wrd[targV]=wrd[srcV]
			targV += 1
			srcV += 1
			lenV-=1
		}
	}


	private class func moveInternallyInv(_ wrd:inout [LogicWord?], src:UInt32, targ:UInt32, len:UInt32) {
		var lenV = len
		var targV = Int(targ)
		var srcV = Int(src)
		while lenV>0 {
			wrd[targV]=wrd[srcV]
			targV-=1
			srcV-=1
			lenV-=1
		}
	}


	private class func copyPart(_ src:[LogicWord?], srcStart:UInt32, srcLen:UInt32, trg: inout [LogicWord?], trgInd:UInt32) {
		var srcInd:Int = Int(srcStart)
		var trgIndV:Int = Int(trgInd)
		var srcLenV:Int = Int(srcLen)

		while srcLenV>0 {
			trg[trgIndV]=src[srcInd]
			srcLenV-=1
			trgIndV+=1
			srcInd+=1
		}
	}


	public func replace(_ newPhrase:LogicPhrase, _ oldPhraseLen:UInt32, _ sel:[UInt32]) {
		let words2:[LogicWord?] = newPhrase.words
		let newPhraseLen:UInt32 = newPhrase.length
		let selLen:UInt32 = UInt32(sel.count)
		let phraseDif:Int = Int(newPhraseLen)-Int(oldPhraseLen)
		let totalDif:Int = phraseDif*Int(selLen)
		var	i:Int,
			j:Int = 0,
			h:Int

		if selLen==0 {return}

		if phraseDif==0 {
			for k in 0..<Int(selLen) {
				i = Int(sel[k])
				for j in 0..<Int(oldPhraseLen) {
					words[i] = words2[j]
					i+=1
				}
			}
		}


		else if phraseDif<0 { //new is smaller
			i = Int(sel[0])		//we point to the first match
			for k in 0..<Int(selLen) {
				LogicPhrase.copyPart(words2, srcStart:0, srcLen:newPhraseLen, trg:&words, trgInd:UInt32(i))

				i += Int(newPhraseLen)									//i points to the symbol after the replacment (src)
				j = i-Int(phraseDif)*(k+1)								//j points to the symbol after the match (trg)
				h = (k<Int(selLen)-1) ? Int(sel[k+1])-j : Int(length)-j	//number of symbols to be moved
				LogicPhrase.moveInternally(&words, src:UInt32(j), targ:UInt32(i), len:UInt32(h))

				i += h		//update for next copying
			}
		}

		else if Int(length)+totalDif<=words.count {
			i = Int(length)+totalDif-1										//i = last target address
			for k in (0...Int(selLen)-1).reversed() {						//k = sel array index
				j = (k==Int(selLen)-1) ? Int(length)-1 : Int(sel[k+1])-1	//j = last source address
				h = j - Int(sel[k]) - Int(oldPhraseLen) + 1					//h is how many symbols to be transfered
				LogicPhrase.moveInternallyInv(&words,src:UInt32(j), targ:UInt32(i), len:UInt32(h))
				i -= h														//update for next copying

				LogicPhrase.copyPart(words2, srcStart:0, srcLen:newPhraseLen, trg:&words, trgInd:UInt32(i+1) - newPhraseLen)
				i -= Int(newPhraseLen)										 //update for next copying
			}
		}

		else {
			var tmp:[LogicWord?] = [LogicWord?](
				repeating: nil,
				count:Int(length) + totalDif + Int(LogicPhrase.SIZE_INCREMENT)
			)

			i = Int(length)+totalDif-1
			for k in (0...Int(selLen)-1).reversed() {
				j = (k==Int(selLen)-1) ? Int(length)-1 : Int(sel[k+1])-1	//j = last source address
				h = j - Int(sel[k]) - Int(oldPhraseLen) + 1						//h is how many symbols to be transfered

				LogicPhrase.copyPart(words, srcStart:UInt32(j-h+1), srcLen:UInt32(h), trg:&tmp, trgInd:UInt32(i-h+1))
				i -= h												 		//update for next copying

				LogicPhrase.copyPart(words2, srcStart:0, srcLen:newPhraseLen, trg:&tmp, trgInd:UInt32(i-Int(newPhraseLen)+1))
				i -= Int(newPhraseLen)
			}

			//copy begining
			LogicPhrase.copyPart(words, srcStart:0, srcLen:UInt32(i+1), trg:&tmp, trgInd:0)
			words = tmp
		}

		length = UInt32( Int(length) + totalDif )
	}


//SERIALIZATION
	public override func toJson() -> String {
		var ret = "\""
		for i in 0..<Int(length) {
			if words[i] == nil { ret += "NULL " }
			else { ret += words[i]!.toString() + " " }
		}
		return ret + "\""
	}
}
