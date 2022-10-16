//
//  ValueAnimator.swift
//  PhotoArt
//
//  Created by Rustam Khakhuk on 16.10.2022.
//

import Foundation
import QuartzCore

class ValueAnimator {
    private var duration: CGFloat
    private var animation: (CGFloat) -> Void
    private var complition: (Bool) -> Void
    private var delay: CGFloat
    private var curve: (CGFloat) -> CGFloat

    private var timer: CADisplayLink!
    private var localTime: CGFloat = 0

    init(
        duration: CGFloat,
        animation: @escaping (CGFloat) -> Void,
        delay: CGFloat = 0,
        curve: @escaping (CGFloat) -> CGFloat = { $0 },
        complition: @escaping (Bool) -> Void = { _ in }
    ) {
        self.duration = duration
        self.animation = animation
        self.delay = delay
        self.curve = curve
        self.complition = complition
    }

    func start() {
        localTime = -delay
        timer = CADisplayLink(target: self, selector: #selector(onAnimation))
        timer.add(to: .main, forMode: .common)
    }

    func stop() {
        complition(false)
        timer.isPaused = true
        timer.invalidate()
    }

    @objc private func onAnimation() {
        localTime += timer.duration
        guard localTime > 0 else { return }

        if localTime > duration {
            localTime = duration
            animation(curve(1))
            complition(true)
            timer.isPaused = true
            timer.invalidate()
        } else {
            animation(curve(localTime / duration))
        }
    }
}
