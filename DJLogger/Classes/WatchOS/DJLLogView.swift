/*
 The MIT License (MIT)

 Copyright (c) 2021 David Jonsén

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import SwiftUI

private extension DJLLogger.Level {
    
    var color: Color {
        switch self {
        case .trace, .debug:
            return .green
        case .warning:
            return .yellow
        case .error, .critical:
            return .red
        }
    }
}

struct DJLLogView: View {
    
    let log: DJLFileLog
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading, spacing: 8) {
                
                
                HStack(alignment: .center) {
                    
                    VStack(alignment: .leading, spacing: 2) {
                        
                        Text(log.label)
                            .font(.caption2)
                            .foregroundColor(.blue)
                        
                        Text(log.date, style: .time)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer(minLength: 0)
                    
                    Text(log.level.name)
                        .foregroundColor(.white)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background {
                            log.level.color
                                .mask {
                                    RoundedRectangle(cornerRadius: 6)
                                }
                        }
                }
                
                Text(log.message)
                    .font(.body)
                    .padding(.vertical, 2)
                
                Text(log.meta)
                    .font(.system(size: 11))
                    .italic()
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background {
            
            Color(uiColor: UIColor(red: 16/255.0, green: 16/255.0, blue: 16/255.0, alpha: 1))
                .mask {
                    RoundedRectangle(cornerRadius: 12)
                }
        }
        .padding(.vertical, 2)
    }
}

//struct DJLLogView_Previews: PreviewProvider {
//    static var previews: some View {
//        DJLLogView()
//    }
//}
