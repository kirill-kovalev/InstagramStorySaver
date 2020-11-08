//
//  Fonts.swift
//  InstaSaver
//
//  Created by Кирилл on 27.10.2020.
//

import UIKit

/*
100    Extra Light or Ultra Light
200    Light or Thin
300    Book or Demi
400    Normal or Regular
500    Medium
600    Semibold, Demibold
700    Bold
800    Black, Extra Bold or Heavy
900    Extra Black, Fat, Poster or Ultra Black
*/

extension UIFont{
	static let header = FontFamily.SFProDisplay.semibold.font(size: 36)
	static let title = FontFamily.SFProDisplay.semibold.font(size: 24)
	static let subtitle = FontFamily.SFProDisplay.semibold.font(size: 18)
	static let subtitleGray = FontFamily.SFProDisplay.medium.font(size: 14)
	
	static let listItemTitle = FontFamily.SFProDisplay.regular.font(size: 16)
	static let listItemSubtitle = FontFamily.SFProDisplay.regular.font(size: 12)
	static let searchfield = FontFamily.SFProDisplay.light.font(size: 18)
}
